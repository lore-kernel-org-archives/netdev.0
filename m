From: Ben Greear <greearb@candelatech.com>
Subject: Re: netdev_ops?
Date: Tue, 22 Jul 2003 23:24:00 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1E2A00.5080506@candelatech.com>
References: <3F1E17BC.30100@candelatech.com>	<20030722220745.379a73c6.davem@redhat.com>	<3F1E1D62.90009@candelatech.com> <20030722230215.284dd270.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030722230215.284dd270.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Tue, 22 Jul 2003 22:30:10 -0700
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Any interest in a lower-risk netdev-ops lite?
> 
> 
> Not really.
> 
> Nobody is really helped with this, not even you.  It makes almost no
> sense to make a driver only work with a 2.4.x kernel that has this
> netdev-ops-lite thing patched into it, because then it doesn't work on
> all the bazillion other 2.4.x kernels out there.


My goal is a place to add new generic net-device ioctls without having
to worry about testing the ioctls on various platforms (You've said
before you don't like when I try to add new ioctls because I break SPARC and
who knows what else...)

My patch looks like this, and it has zero impact on drivers.  It's primary
benefit is to get around adding more ioctls:

### Line 2304 or so, default case of the dev_ifsioc switch... ###

  		default:
+                        /* Handle some generic ethtool commands here */
+                        if (cmd == SIOCETHTOOL) {
+                                u32 cmd = 0;
+                                if (copy_from_user(&cmd, ifr->ifr_data, sizeof(cmd))) {
+                                        return -EFAULT;
+                                }
+
+                                if (cmd == ETHTOOL_GNDSTATS) {
+
+                                        struct ethtool_ndstats* nds = (struct ethtool_ndstats*)(ifr->ifr_data);
+
+                                        /* Get net-device stats struct, will save it in the space
+                                         * passed in to us in ifr->ifr_data.  Would like to use
+                                         * ethtool, but it seems to require specific driver support,
+                                         * when this is a general purpose netdevice request...
+                                         */
+                                        struct net_device_stats *stats = dev->get_stats(dev);
+                                        if (stats) {
+                                                if (copy_to_user(nds->data, stats, sizeof(*stats))) {
+                                                        return -EFAULT;
+                                                }
+                                        }
+                                        else {
+                                                return -EOPNOTSUPP;
+                                        }
+                                        return 0;
+                                }
+                        }
+
+
+
### Fall through to the rest of the ioctl (ethtool included) handling...



-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear

From: Ben Greear <greearb@candelatech.com>
Subject: Re: Function to determine if IP exists on a net-device?
Date: Thu, 20 Nov 2003 00:30:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBC7BA4.9070501@candelatech.com>
References: <3FBB36F2.7030402@candelatech.com>	<20031119173103.1938bc51.davem@redhat.com>	<3FBC215B.2090100@candelatech.com> <20031119181529.4c2b861a.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
In-Reply-To: <20031119181529.4c2b861a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> On Wed, 19 Nov 2003 18:05:15 -0800
> Ben Greear <greearb@candelatech.com> wrote:
> 
> 
>>Is there not a more direct access if I already have the netdevice in question?
>>ie, can I get at the list by looking at dev->ip_ptr struct?
> 
> 
> Yes, using dev->ip_ptr as a "struct in_device *in_dev"
> do something like this:
> 
> 	struct in_ifaddr *ifa;
> 
> 	read_lock(&in_dev->lock);
> 	for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
> 		if (inet_ifa_match(my_addr, ifa)) {
> 			/* match */
> 		}
> 	}
> 	read_unlock(&in_dev->lock);
> 
> should work...
> 


The inet_ifa_match thing uses a mask, and was matching everything on the subnet,
or something...

This seems to work though:

static int is_ip_on_dev(struct net_device* dev, __u32 ip) {
	int rv = 0;
	struct in_device* in_dev = in_dev_get(dev);
	if (in_dev) {
		struct in_ifaddr *ifa;

		read_lock(&in_dev->lock);
		for (ifa = in_dev->ifa_list; ifa; ifa = ifa->ifa_next) {
			if (ifa->ifa_address == ip) {
				/* match */
				rv = 1;
				break;
			}
		}
		read_unlock(&in_dev->lock);
		in_dev_put(in_dev);
	}
	return rv;
}


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

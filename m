From: Ben Greear <greearb@candelatech.com>
Subject: FWD:  setting skb->dev to vlan device in vlan_hwaccel_rx is wrong
 ...
Date: Fri, 15 Oct 2004 16:27:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41705CF2.9050303@candelatech.com>
References: <OF1AA93F13.5E509602-ONC1256F2E.00506148-C1256F2E.00551602@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "Linux 802.1Q VLAN" <vlan@candelatech.com>, pavlic@de.ibm.com,
        netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>
In-Reply-To: <OF1AA93F13.5E509602-ONC1256F2E.00506148-C1256F2E.00551602@de.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Earlier, Frank had written as explanation:

 > Hi ,
 > I found a problem using vlan_hwaccel_rx function to pass skb to the stack.
 > vlan_hwaccel_rx sets skb->dev to the vlan device accordingly to the vlan
 > id.
 > After checking pkt_type netif_rx is called in non polling mode .  vlan_skb_recv
 > is called with a wrong skb->dev setting as the receive function is still
 > expecting  the real device .... , the problem also exists in 2.4 vlan code ...


I am not so sure we need this patch, as I believe the net_rx_skb methods should
handle receiving a pkt with a vlan-device as the skb->dev.

Frank, could you explain the problem you see in more detail?

Dave, since you did the hw-accel work, what do you think of this patch?


Frank Pavlic wrote:
> Kernel 2.6.8.1 ....
> 
> I'm sorry about 2.4 kernel it was an old one ..., but nevertheless 2.4.27 
> hasn't the bug fixed yet ..
> 
> patch for Kernel 2.4.27 :
> 
> --- include/linux/if_vlan.old   2004-04-14 15:05:40.000000000 +0200
> +++ include/linux/if_vlan.h     2004-10-15 17:16:09.000000000 +0200
> @@ -183,7 +183,7 @@
>                         skb->pkt_type = PACKET_HOST;
>                 break;
>         };
> -
> +       skb->dev = skb->real_dev;
>         return (polling ? netif_receive_skb(skb) : netif_rx(skb));
>  }
> 
> 
> 
> 
> 
> 
> Ben Greear <greearb@candelatech.com> 
> Sent by: vlan-bounces@candelatech.com
> 14.10.2004 19:07
> Please respond to
> "Linux 802.1Q VLAN"
> 
> 
> To
> "Linux 802.1Q VLAN" <vlan@candelatech.com>
> cc
> 
> Subject
> Re: [VLAN]      |PATCH| setting skb->dev  to vlan device in 
> vlan_hwaccel_rx is      wrong ...
> 
> 
> 
> 
> 
> 
> Frank Pavlic wrote:
> 
>>IHi ,
>>I found a problem using vlan_hwaccel_rx function to pass skb to the 
> 
> stack.
> 
>>vlan_hwaccel_rx sets skb->dev to the vlan device accordingly to the vlan 
> 
> 
>>id.
>>After checking pkt_type netif_rx is called in non polling mode . 
>>vlan_skb_recv 
>>is called with a wrong skb->dev setting as the receive function is still 
> 
> 
>>expecting 
>>the real device .... , the problem also exists in 2.4 vlan code ...
> 
> 
> While looking at the 2.4.27 code, I think that this fix may
> already be in.
> 
> 2.6.7 also looks correct.
> 
> What versions did you base these patches off of?
> 
> Ben
> 
> 
>>Frank
>>
>>Kernel 2.6:
>>
>>Index: include/linux/if_vlan.h
>>===================================================================
>>RCS file: /home/cvs/linux-2.5/include/linux/if_vlan.h,v
>>retrieving revision 1.10
>>diff -B -u -b -r1.10 if_vlan.h
>>--- include/linux/if_vlan.h     17 Aug 2004 11:50:08 -0000      1.10
>>+++ include/linux/if_vlan.h     14 Oct 2004 13:43:58 -0000
>>@@ -184,7 +184,7 @@
>>                        skb->pkt_type = PACKET_HOST;
>>                break;
>>        };
>>-
>>+       skb->dev = skb->real_dev;
>>        return (polling ? netif_receive_skb(skb) : netif_rx(skb));
>> }
>>
>>KERNEL > 2.4.21:
>>
>>Index: include/linux/if_vlan.h
>>===================================================================
>>RCS file: /home/cvs/linux-2.3/include/linux/if_vlan.h,v
>>retrieving revision 1.6
>>diff -B -u -b -r1.6 if_vlan.h
>>--- include/linux/if_vlan.h     17 Feb 2003 10:36:43 -0000      1.6
>>+++ include/linux/if_vlan.h     14 Oct 2004 13:45:39 -0000
>>@@ -147,6 +147,7 @@
>>                                    unsigned short vlan_tag, int 
> 
> polling)
> 
>> {
>>        struct net_device_stats *stats;
>>+       struct net_device *real_dev = skb->dev;
>>
>>        skb->dev = grp->vlan_devices[vlan_tag & VLAN_VID_MASK];
>>        if (skb->dev == NULL) {
>>@@ -182,7 +183,7 @@
>>                        skb->pkt_type = PACKET_HOST;
>>                break;
>>        };
>>-
>>+       skb->dev = real_dev;
>>        return (polling ? netif_receive_skb(skb) : netif_rx(skb));
>> }
>>_______________________________________________
>>Vlan mailing list
>>Vlan@lanforge.com
>>http://www.lanforge.com/mailman/listinfo/vlan

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

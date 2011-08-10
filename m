From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: BUG: Bisected Gianfar in bridge not forwarding packets (was:
 3.0-rc1 Bridge not forwarding unicast packages)
Date: Wed, 10 Aug 2011 10:37:33 +0200
Message-ID: <20110810083732.GA1909@minipsycho.brq.redhat.com>
References: <CAMvAeqOA0=FnjB2oPPCEYpkXdKrmqOs+MwAqszV5sTGys_a3mQ@mail.gmail.com>
 <20110810070722.GA2150@minipsycho>
 <CAMvAeqNA9Wcr3bO+Vya4gt2YC47oe=-A8Fxnswdj0ozD5tfZtQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@vyatta.com, sebastian.belden@googlemail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Michael Guntsche <mguntsche@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMvAeqNA9Wcr3bO+Vya4gt2YC47oe=-A8Fxnswdj0ozD5tfZtQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Aug 10, 2011 at 09:40:50AM CEST, mguntsche@gmail.com wrote:
>On Wed, Aug 10, 2011 at 9:07 AM, Jiri Pirko <jpirko@redhat.com> wrote:
>> Wed, Aug 10, 2011 at 02:50:20AM CEST, mguntsche@gmail.com wrote:
>>>Good evening/morning,
>>>
>>>> I just upgraded my router/bridge combo to 3.1-rc1 from 3.0 for
>>>> testing. On a first look everything seemed to work fine, but when I
>>>> tried to connect via openvpn to my internal network (tap0 being bridged
>>>> with the internal network) I noticed that I was not able to access the
>>>> server on my internal network. I could access the bridge (which is
>>>> acting as the openvpn server as well) just fine though.
>>>> To debug this I ran tcpdump on the openvpn client and started a ping to the
>>>> internal network. I could see the ARP requests being answered.....
>>><snip>
>>>
>>>After much digging and testing I found the commit that causes the
>>>problem for me here.
>>>
>>>87c288c6e gianfar: do vlan cleanup
>>>
>>>Before this commit my bridge works fine. I simplified the test case
>>>and just tried to access the server from a local wireless device with
>>>gets also bridged via
>>>a gianfar nic to the wired lan. Before commit 87c288c6e I can ping the
>>>device from the internal network afterwards it stops.
>>>For testing purposes I reverted this commit (plus some others to make
>>>the code compile) and it started working again.
>>>The hardware is a routerboard with three onboard nics two of em gianfar.
>>>The gianfar nics do not support any kind of offloading,
>>
>> Thanks for testing/report. I'm not sure I understand your simplified
>> case :(
>Sorry if my explanation was confusing but it was late night/morning
>when I wrote it.
>
>The setup is quite easy.
>
>WLAN ----->|Bridge|<----- Wired Lan (gianfar nic)
>
>Client (in WLAN): 192.168.42.55
>Bridge: 192.168.42.1
>Server (on Wired): 192.168.42.127
>
>With your patch the Bridge can ping the client and the server, but the
>client cannot reach the server and vice-versa.

This is very interesting. Can you please find out of packets get lost on
tx or rx of gianfar? Please try to watch the trafic by tcpdump on bridge
and on gianfar device.


>
>>
>> Anyway, gianfar supports rx/tx vlan accel. Would you please try to turn
>> it on/off manually by ethtool to see if it works in some setup?
>The gianfar chip in this routerboard does NOT support vlan accel it is
>a TSEC model.
>ethtool complains that this feature is not supported.

What routerboard is it? Maybe I can get one to see this myself. Thanks.


Can you please send me output of following command?
"cat /sys/class/net/[gianfar devname]/features"

Also, please try with following testing patch:


diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 2659daa..2727bb7 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -2711,8 +2711,8 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb,
 	skb->protocol = eth_type_trans(skb, dev);
 
 	/* Set vlan tag */
-	if (fcb->flags & RXFCB_VLN)
-		__vlan_hwaccel_put_tag(skb, fcb->vlctl);
+	//if (fcb->flags & RXFCB_VLN)
+	//	__vlan_hwaccel_put_tag(skb, fcb->vlctl);
 
 	/* Send the packet up the stack */
 	ret = netif_receive_skb(skb);

>
>>
>> I presume you have no vlans involved in your setup, right?
>No, there are no vlans in my setup.
>
>
>>>Is it possible that the new code is tripped up by the bridge offload
>>>parameters somehow and thinks that the gianfar nic supports it as
>>>well?
>>
>> I don't see how now. Outside the bridge all is working correctly?
>Yes I can access the server from the bridge so the network is working.
>For me it looks like that the packets are just dropped when they
>should go through the bridge.
>
>Kind regards,
>Michael

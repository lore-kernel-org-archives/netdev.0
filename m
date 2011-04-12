From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.39-rc2 boot crash
Date: Tue, 12 Apr 2011 17:39:51 +0200
Message-ID: <4DA47247.20700@trash.net>
References: <20110406184753.GA7691@mgebm.net> <1302115953.8094.217.camel@nimitz> <20110406212041.GA2596@mgebm.net> <20110406.142157.68145422.davem@davemloft.net> <20110406220512.GA2460@mgebm.net> <4D9D9AA4.6060304@trash.net> <20110411210746.GA2453@mgebm.net> <20110411220657.GB5783@ioremap.net> <4DA44A73.3060801@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080107070709040403020402"
Cc: Eric B Munson <emunson@mgebm.net>,
	David Miller <davem@davemloft.net>, dave@linux.vnet.ibm.com,
	linux-kernel@vger.kernel.org, gregkh@suse.de,
	ksrinivasan@novell.com, NetDev <netdev@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DA44A73.3060801@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080107070709040403020402
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

On 12.04.2011 14:49, Patrick McHardy wrote:
> On 12.04.2011 00:06, Evgeniy Polyakov wrote:
>> Hi.
>>
>> On Mon, Apr 11, 2011 at 05:07:47PM -0400, Eric B Munson (emunson@mgebm.net) wrote:
>>>> I can't figure this out, the only thing that should have changed is the
>>>> time the initial PROC_CN_MCAST_LISTEN message is received. Apparently
>>>> at that point connector is not fully initialized yet. Please post your
>>>> config and the full boot log. Thanks.
>>>>
>>>
>>> I am still seeing this on Linus' tree, is there anything more I can do to help
>>> track the problem?
> 
> Sorry, I had a hardware failure, I'm back working on this now.
> 
>> Patrick, do you need my assist on this bug?
> 
> Thanks, but I can meanwhile reproduce the problem, so I think I
> should have a fix soon.

I think this patch should fix the problem. Eric, could you please
give it a try?




--------------080107070709040403020402
Content-Type: text/x-patch;
 name="cn.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="cn.diff"

commit ad676e0dbbe8658ce46e192f449689bf3011bdf5
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Apr 12 17:37:04 2011 +0200

    connector: fix skb double free in cn_rx_skb()
    
    When a skb is delivered to a registered callback, cn_call_callback()
    incorrectly returns -ENODEV after freeing the skb, causing cn_rx_skb()
    to free the skb a second time.
    
    Reported-by: Eric B Munson <emunson@mgebm.net>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/drivers/connector/connector.c b/drivers/connector/connector.c
index d770058..219d88a 100644
--- a/drivers/connector/connector.c
+++ b/drivers/connector/connector.c
@@ -142,6 +142,7 @@ static int cn_call_callback(struct sk_buff *skb)
 		cbq->callback(msg, nsp);
 		kfree_skb(skb);
 		cn_queue_release_callback(cbq);
+		err = 0;
 	}
 
 	return err;

--------------080107070709040403020402--

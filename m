From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP][PATCHES] Network xmit batching - tg3 support
Date: Tue, 03 Jul 2007 09:09:48 -0400
Message-ID: <1183468188.5159.73.camel@localhost>
References: <OFB311484E.057E34E9-ON652572F3.001D5838-652572F3.0022766D@in.ibm.com>
	 <1181216629.4064.22.camel@localhost> <20070619132148.GA32078@2ka.mipt.ru>
	 <20070619133333.GA19667@2ka.mipt.ru> <20070619140038.GA13629@2ka.mipt.ru>
	 <1182270529.4968.73.camel@localhost>
	 <18040.5105.715624.286924@robur.slu.se>
	 <1182275300.4968.83.camel@localhost> <1182989145.5155.81.camel@localhost>
	 <1183411245.6609.16.camel@teletran1>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>,
	Gagan Arneja <gaagaan@gmail.com>, netdev@vger.kernel.org,
	Rick Jones <rick.jones2@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>,
	Jeff Garzik <jeff@garzik.org>,
	Michael Chan <mchan@broadcom.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:22907 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059AbXGCNJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2007 09:09:58 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1787134wxd
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2007 06:09:54 -0700 (PDT)
In-Reply-To: <1183411245.6609.16.camel@teletran1>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-02-07 at 14:20 -0700, Matt Carlson wrote:


> 
> Hi Jamal.  I'll be testing your patch soon,

much thanks. Please let me know if you need help while doing this.
What tools are you planning to test with? I have tested this patch
with pktgen on a dual opteron/tg3-buggy. 
There is an outstanding issue in regards to clocksource - however the
batch does well regardless of the clock source.

>  but I wanted to point out a
> bug in the patch.  The patch defines TG3_SKB_CB() as follows :
> 
> #define TG3_SKB_CB(__skb) ((struct tg3_tx_cbdata *)&((__skb)->cb[0]))
> 
> This definition will collide with the VLAN macros if TG3_VLAN_TAG_USED
> is set.  vlan_tx_tag_get() is defined as :
> 
> #define vlan_tx_tag_get(__skb)  (VLAN_TX_SKB_CB(__skb)->vlan_tag)
> 
> VLAN_TX_SKB_CB is defined as :
> 
> #define VLAN_TX_SKB_CB(__skb) \
>         ((struct vlan_skb_tx_cookie *)&((__skb)->cb[0]))
> 

yikes. Thanks for catching that - I thought i had this pretty much
covered after scanning the source. So that bug exists on the e1000 as
well.
[It sounds very dangerous to me the way skb->cb is being used by the
vlan code (i.e requires human intervention/knowledge to catch it as an
issue). I had no freaking idea the vlan code was using it. Maybe a huge
comment somewhere on how these cbs are being used by drivers would help
or even a registration on startup to just make sure there is no conflict
at a layer (i have been meaning to do the later for years now). In any
case this is is a digression]. 

In the meantime, changing it to use byte 8 and above should do it? i.e.
#define TG3_SKB_CB(__skb) ((struct tg3_tx_cbdata *)&((__skb)->cb[8]))

There are 48 bytes there on the skb-cb, so there should be plenty.

> Also, I think the count, max_per_txd, and nr_frags fields of the
> tg3_tx_cbdata struct are not needed.

Yes, you are right. That was a result of the LinuxWay(tm) (aka cutnpaste
from the e1000 which needs them), Can you send me a patch for that and
TG3_SKB_CB? 

cheers,
jamal


From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: change the way e1000 is handling short VLAN frames
Date: Fri, 21 Sep 2007 15:02:38 -0700
Message-ID: <41b516cb0709211502v5a9931bfx267d163c51bd4958@mail.gmail.com>
References: <1190359905.3551.28.camel@magi.nadr>
	 <1190379015.3551.57.camel@magi.nadr>
	 <1190381841.4231.10.camel@localhost>
	 <1190382366.4231.13.camel@localhost>
	 <46F3E695.7010604@candelatech.com>
	 <1190409160.4231.29.camel@localhost> <46F435CD.1090502@intel.com>
	 <1190410187.4231.43.camel@localhost> <46F438F3.5030201@intel.com>
	 <1190411007.4231.54.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Ben Greear" <greearb@candelatech.com>,
	"Emil Micek" <emil.micek@tkrjasek.cz>,
	"netdev mailing list" <netdev@vger.kernel.org>,
	Jesse <jesse.brandeburg@intel.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.190]:30658 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756641AbXIUWCk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2007 18:02:40 -0400
Received: by fk-out-0910.google.com with SMTP id z23so912679fkz
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2007 15:02:38 -0700 (PDT)
In-Reply-To: <1190411007.4231.54.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/21/07, jamal <hadi@cyberus.ca> wrote:
> On Fri, 2007-21-09 at 14:34 -0700, Kok, Auke wrote:
>
> > I never saw any bugreports about e1000 not being able to accept vlan packets
> > because of this, so I'm quite certain it works OK, feel free to find me a case
> > where this isn't so :)
>
> If you tell me it can be done on the rx, i will take your word for it;->
> Emil can certainly verify it.
> The tx you certainly have issues - Look at one of the suggestions from
> Chris, i think it is resolvable.

I'd say that devices that can't receive 64 bytes VLAN tagged frames
have an issue, but for the sake of interoperability and solving Emil's
problem I'm willing to discuss how a change to e1000 would work  ;-)

The simplest option is to add software small frame padding all the
time.  It won't catch software tagged frames if they were generated
somehow, but should fix the hardware tagged ones to be 68 bytes on the
wire.  If you were worried about software tagged frames then replacing
ETH_ZLEN with VLAN_ETH_ZLEN would pad all frames, VLAN or not, to 68
bytes.

Emil, this patch will probably do what you want.

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 4a22595..34e3d18 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3284,6 +3284,9 @@ e1000_xmit_frame(struct sk_buff *skb, struct
net_device *netdev)
                return NETDEV_TX_OK;
        }

+       if (skb_padto(skb, ETH_ZLEN))
+               return NETDEV_TX_OK;
+
        /* 82571 and newer doesn't need the workaround that limited descriptor
         * length to 4kB */
        if (adapter->hw.mac_type >= e1000_82571)

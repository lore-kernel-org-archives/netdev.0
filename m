From: Eric Leblond <eric@regit.org>
Subject: Re: [RFC PATCH] af_packet: don't to defrag shared skb
Date: Fri, 07 Dec 2012 22:46:08 +0100
Message-ID: <1354916768.4530.18.camel@tiger2>
References: <1354906561-4695-1-git-send-email-eric@regit.org>
	 <20121207.153134.25835204617509469.davem@davemloft.net>
	 <1354915824.9124.11.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, linville@tuxdriver.com
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ks28632.kimsufi.com ([91.121.96.152]:44205 "EHLO
	ks28632.kimsufi.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623Ab2LGVqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 16:46:49 -0500
In-Reply-To: <1354915824.9124.11.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Fri, 2012-12-07 at 22:30 +0100, Johannes Berg wrote:
> 
> > Wireless folks, please take a look.  The issue is that,
> > under the circumstances listed below, we get SKBs in
> > the AF_PACKET input path that are shared.
> 
> Ok so I took a look, but I can't see where the wireless stack is going
> wrong.
> 
> > Given the logic present in ieee80211_deliver_skb() I think
> > the mac80211 code doesn't expect this either.
> 
> This is correct, but the driver should never give us a shared skb. From
> the other mail it seems Eric is using iwlwifi, which is definitely not
> creating shared SKBs. Nothing in mac80211 creates them either.
> 
> > > I've observed this crash under the following condition:
> > >  1. a program is listening to an wifi interface (let say wlan0)
> > >  2. it is using fanout capture in flow load balancing mode
> > >  3. defrag option is on on the fanout socket
> 
> How do you set this up, and what does it do? I'd like to try to
> reproduce this.



> > >  4. the interface disconnect (radio down for example)
> > >  5. the interface reconnect (radio switched up)
> > >  6. once reconnected a single packet is seen with skb->users=2
> 
> That's interesting. A single one seems odd. I might have expected two,
> but not one. Well, since you removed the crash ... I guess I'll have to
> believe that there's just one and the second one doesn't show up because
> we crashed before :-)

It was the case with initial code but I've suppressed the BUG() call and
replaced it with a return ;)

> > So if we look at ieee80211_deliver_skb(), it has code to deal with unaligned
> > packet headers, wherein it memoves() the data into a better aligned location.
> > 
> > But if these SKBs really are skb_shared(), this packet data
> > modification is illegal.
> > 
> > I suspect that the assumptions built into this unaligned data handling
> > code, and AF_PACKET, are correct.  Meaning that we should never see
> > skb_shared() packets here.  We just have a missing skb_copy()
> > somewhere in mac80211, Johannes can you please take a look?
> 
> My first theory was related to multiple virtual interfaces, but Eric
> didn't say he was running that, but we use skb_copy() for that in
> ieee80211_prepare_and_rx_handle(). That's not necessarily the most
> efficient (another reason for drivers to use paged RX here) but clearly
> not causing the issue.
> 
> The only other theory I can come up with right now is that the skb_get()
> happens in deliver_skb via __netif_receive_skb. Keeping in mind that
> wpa_supplicant might have another packet socket open for authentication
> packets, that seems like a possibility. I'll test it once I figure out
> how to do this "defrag" option you speak of :)

I've no simple code available to test it. I've add the problem when
running suricata. Maybe you could use it. It is packaged in most
distribution now.
To enable packet fanout. Modify default /etc/suricata/suricata.yaml to
have something like:
af-packet:
  - interface: wlan0
    # Number of receive threads (>1 will enable experimental flow pinned
    # runmode)
    threads: 3

Start it with: suricata --af-packet=wlan0
Then get wlan0 interface down and up. After a few seconds, the crash
will occur.
It is a bit complicated for a simple test case. I can cook a little
example code if you want.

BR,
-- 
Eric Leblond <eric@regit.org>
Blog: https://home.regit.org/

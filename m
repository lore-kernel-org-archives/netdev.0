From: Andrew Gallatin <gallatin@myri.com>
Subject: [PATCH v3 resend net-next 0/2] myri10ge: LRO to GRO conversion
Date: Fri, 30 Nov 2012 13:31:57 -0500
Message-ID: <1354300319-30771-1-git-send-email-gallatin@myri.com>
References: <20121130.121705.1923519039781698493.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f174.google.com ([209.85.161.174]:48233 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755822Ab2K3Siv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 13:38:51 -0500
Received: by mail-gg0-f174.google.com with SMTP id k2so117552ggd.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 10:38:51 -0800 (PST)
In-Reply-To: <20121130.121705.1923519039781698493.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I'm resending this after fixing email client issues.

The following patchset is a resubmission of '[PATCH resend net-next 0/3]
myri10ge: LRO to GRO conversion', and converts myri10ge from using
the old inet_lro interface to GRO, and to do vlan tag decap in
the driver so as to not suffer a performance penalty for vlan
tagged traffic due to the conversion.

Changes this time are:

- Clean up some messy indenting & parens in
  "2/3 myri10ge-Add-vlan-rx-for-better-GRO-perf"
  and store the vlan hdr csum in a variable, so now we are not calling
  csum_partial() nested so deeply it spreads across 3 lines

- Folded 3/3 myri10ge-Use-skb_fill_page_desc into 1/3
  myri10ge-Convert-from-LRO-to-GRO.patch since it is really just small
  part of the LRO removal cleanup.  It was originally a separate patch
  because I noticed the cleanup at the last second, and was too lazy
  to fold it into the first patch where it belonged.

Note that a naive LRO->GRO conversion of myri10ge will result in a
performance regression for vlan tagged frames.  This is because
myri10ge does not offer hardware vlan tag offload, and because GRO
requires hardware vlan tag offload to aggregate vlan tagged frames.

To address this performance regression, I have implemented vlan tag
popping in the myri10ge driver, as it seems to be the lesser of two
evils.  As eric.dumazet@gmail.com commented when I asked about this on
netdev: "Given GRO assumes NIC does hardware vlan
offloading, I guess I would chose to do that.  It seems unfortunate to
add vlan decap in GRO path, already very complex." 

Andrew Gallatin (2):
  myri10ge: Convert from LRO to GRO
  myri10ge: Add vlan rx for better GRO perf.

 drivers/net/ethernet/myricom/Kconfig             |    1 -
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c |  275 ++++++----------------
 2 files changed, 74 insertions(+), 202 deletions(-)

-- 
1.7.9.5

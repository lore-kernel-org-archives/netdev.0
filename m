From: Hideo AOKI <haoki@redhat.com>
Subject: Re: [RFC] [NET] [0/2] pskb_expand_head() bugfix
Date: Fri, 28 Mar 2008 21:01:04 -0400
Message-ID: <47ED94D0.7060902@redhat.com>
References: <47E946C8.6020006@redhat.com> <20080325235536.GB30298@gondor.apana.org.au> <47EAB667.6010308@redhat.com> <20080327001349.GA8569@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>, haoki@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754173AbYC2BBL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Mar 2008 21:01:11 -0400
In-Reply-To: <20080327001349.GA8569@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Herbert Xu wrote:
> On Wed, Mar 26, 2008 at 04:47:35PM -0400, Hideo AOKI wrote:
>> Or, should I simply add truesize calculation after
>> pskb_expand_head() calls which change truesize?
> 
> Can you do an audit first and tell us how many sites are currently
> buggy?

Sure. I find 24 spots.

Here is the list of caller functions which don't update turesize
or do update turesize without alignment. But I don't confirm yet 
if alignment is really needed in each case.

* macro: 1
  - Missing truesize update
        linux/skbuff.h:1369:	__skb_cow()

* kernel: 1
  - Missing alignment:
        audit.c:1121:		audit_expand()


* ipv4: 5
  - Missing truesize update:
        ipvs/ip_vs_app.c:597:	ip_vs_skb_replace()
        netfilter/nf_nat_helper.c:119: enlarge_skb()
        netfilter.c:72: 	ip_route_me_harder()
	netfilter.c:105: 	ip_xfrm_me_harder()

  - Missing alignment:
        ipcomp.c:63:		ipcomp_decompress()


* core: 5
  - Missing truesize update:
        skbuff.c:741:		skb_realloc_headroom()
	skbuff.c:840: 		skb_pad()
        skbuff.c:979: 		__pskb_pull_tail()
        skbuff.c:2393: 		skb_cow_data()
        pktgen.c:2402: 		process_ipsec()


* netlink: 1
  - Missing alignment:
        af_netlink.c:838:	netlink_trim()


* ipv6: 1
  - Missing alignment:
    	ipcomp6.c:106:		ipcomp6_input()


* netfilter: 1
  - Missing alignment:
        xt_TCPMSS.c:122:	tcpmss_mangle_packet()


* max80211: 8
  - Missing truesize update:
        tx.c:1246:		ieee80211_master_start_xmit()
        tx.c:1503:		ieee80211_subif_start_xmit()
	wpa.c:103:		ieee80211_tx_h_michael_mic_add()
	wpa.c:207:		tkip_encrypt_skb()
	wpa.c:458:		ccmp_encrypt_skb()
	wep.c:99:		ieee80211_wep_add_iv()
	rx.c:146:		ieee80211_rx_monitor()
	rx.c:905:		ieee80211_rx_h_defragment()


* xfrm: 1
  - Missing truesize update:
	xfrm_output.c:30:	xfrm_state_check_space()

Many thanks,
Hideo

--
Hitachi Computer Products (America) Inc.

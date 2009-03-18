From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE]: First release of nftables
Date: Wed, 18 Mar 2009 09:28:03 +0100
Message-ID: <49C0B093.7000908@trash.net>
References: <49C078B6.4020603@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010101060802060404080209"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35267 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752462AbZCRI2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2009 04:28:09 -0400
In-Reply-To: <49C078B6.4020603@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010101060802060404080209
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Patrick McHardy wrote:
> Examples 

The rule snippets under tests/ pretty much all use obsolete syntax,
so I'm attaching a test script (which doesn't make much sense, just
testing features) so people can get a feeling for the syntax.



--------------010101060802060404080209
Content-Type: text/plain;
 name="test"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="test"

#! /home/kaber/src/nf/nft/nftables/src/nft -nf

#include "ipv4-filter"

flush table filter
delete table filter

table filter {
	chain log_drop {
		counter log prefix "drop" drop
	}

	chain log_accept {
		counter log prefix "accept" accept
	}

	chain accept_related {
		counter
		tcp dport < 1024 counter log prefix "drop-related" drop
		udp dport < 1024 counter log prefix "drop-related" drop
		ct helper "sip" counter log prefix "accept-related-sip" accept
		ct helper "ftp" counter log prefix "accept-related-ftp" accept
		ct helper "irc" counter log prefix "accept-related-irc" accept
		counter log prefix "accept-related" accept
	}

	chain accept_stateful {
		counter
		ct state vmap { established => accept, related => jump accept_related }
		counter
	}

	chain input_local {
		counter
		jump accept_stateful
		jump log_accept
	}

	chain output_local {
		counter
		jump accept_stateful
		udp dport { 123, 631, 514} accept
		jump log_accept
	}

	chain input {
		hook NF_INET_LOCAL_IN 0
		counter
		meta iif vmap {				\
			"eth0"  => jump input_local,	\
			"eth1"  => jump input_local,	\
			*	=> continue,		\
		}
		counter
	}

	chain test1 {
		counter
	}

	chain output {
		hook NF_INET_LOCAL_OUT 0
		counter

		meta oif vmap {				\
			"eth0"  => jump output_local,	\
			"eth1"  => jump output_local,	\
			*	=> continue,		\
		} counter

		meta oif {				\
			"eth0",				\
			"eth1",				\
		} counter

		ip daddr vmap {				\
			192.168.0.1 => jump test1,	\
			*	    => continue,	\
		} counter
	}
}

--------------010101060802060404080209--

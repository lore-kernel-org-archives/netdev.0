From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [DCCP] [RFC] [Patchv2 1/1]: Queuing policies -- reworked
	version of Tomasz's patch set
Date: Wed, 16 Apr 2008 07:20:23 +0100
Message-ID: <20080416062023.GA4278@gerrit.erg.abdn.ac.uk>
References: <200804111224.06958.tomasz@grobelny.oswiecenia.net> <20080415151403.GA20735@gerrit.erg.abdn.ac.uk> <20080415152113.GB20735@gerrit.erg.abdn.ac.uk> <200804152001.58528.tomasz@grobelny.oswiecenia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33832 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750977AbYDPGUw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 02:20:52 -0400
Content-Disposition: inline
In-Reply-To: <200804152001.58528.tomasz@grobelny.oswiecenia.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| > | | What happens if application is compiled with dccp_packet_info
| > | | containing only one field (priority) and kernel containing two fields
| > | | (for example priority and later added expiry time)? Wouldn't that
| > | | implementation make extensions to dccp_packet_info impossible?
| > |
| > | Had not looked at it from this point of view. So you are suggesting
| > |
| > | 	if (msg->msg_control != NULL && msg->msg_controllen >= sizeof(*dcp))
| > | 		dcp = (struct dccp_packet_info *)msg->msg_control;
| > |
| > | instead? Agreed, point #1 to change in the patch.
| >
| > No, the above is nonsense. If the application uses an earlier version of
| > the API, then it needs to be recompiled, there is no way it could pretend
| > to have an adequate size.
| >
| That would effectively stop development of any policy. And it's not about 
| pretending the structure has different size, it's just about using only the 
| data that is provided by the application (even though it may be incomplete).
| 
| > So my take is that still the '==' is correct. But maybe this is a known
| > problem?
| >
| I can't see a problem with copying smaller struct to bigger one. It would work 
| like that:
| 1. set default values for in-kernel structure,
| 2. copy min(msg_control, sizeof(struct dccp_packet_info)) bytes from userspace 
| structure to the kernel one.
| 
| In that sense the code above is in fact wrong but the idea alone should be ok.
| -- 
There is a more serious problem here: apparently no one tried to compile
the `qpolicy' subtree since the changes on Monday. It fails with the
BUILD_BUG_ON.

I tried yesterday evening and found that there is not even a possibility
of adding a single field to struct dccp_skb_cb: with the addition of the
inet{,6}_skb_parm, the struct has reached its maximum size of 48 bytes
(try printk("%u", sizeof(struct dccp_skb_cb));).

There is a solution to this, will post a revised patch shortly.

With regard to your point above: I think there is a way of keeping the
framework open without bending over backwards to ensure the binary
compatibility.

My question for you in this regard: which policy can you think of whose
priorities/preferences can not be mapped into an unsigned 32-bit
integer? I think that such a number is sufficiently expressive enough
to cater for a wide range of policies. It can be interpreted as
 * symbolic value (enum)
 * ascii string (similar to DCCP service code)
 * millisecond timeout (with room for up to 7 weeks)
 * microsecond timeout (with room for up to 1.19 hours)
 * priority values (the large range 0..2^32-1 can be partitioned)
 * ... ?



The University of Aberdeen is a charity registered in Scotland, No SC013683.


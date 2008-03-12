From: Philip Craig <philipc@snapgear.com>
Subject: Re: bridge forwarding delay without STP
Date: Wed, 12 Mar 2008 10:49:54 +1000
Message-ID: <47D728B2.2090903@snapgear.com>
References: <87ejah2ole.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ferenc Wagner <wferi@niif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.snapgear.com ([203.143.235.140]:54347 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751480AbYCLAuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2008 20:50:00 -0400
In-Reply-To: <87ejah2ole.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ferenc Wagner wrote:
> why does a bridge without STP enabled respect its forward delay and
> not skip the learning state?  Forward delay is an STP parameter AFAIK
> (and according to the brctl manual), so I can't see why a bridge not
> doing STP should consider it at all.  Please enlighten me (and Cc: as
> I'm not subscribed).

It doesn't make sense to me either.  But since you can disable the
forward delay by setting it to 0, I don't think it's a problem to
leave this capability in, just in case someone wants it.

But a related problem I have seen is that when you set the forward
delay to 0, the bridge does not learn addresses for the first 20
seconds, and so it floods everything during this time.

Here's what I wrote about this back in July (I didn't get any
replies then):

The reason for this is that hold_time() returns 0 after a topology
change, br_fdb_update() is a no-op if hold_time() is 0 (so that
'brctl setmaxage br0 0' can be used to disable learning), and the
topology change flag isn't cleared for max_age seconds, so nothing
is learnt during that time.

It seems that the intent of hold_time() is to expire entries that are
older than forward_delay seconds at the time of the topology change,
which it does, but then it keeps on checking this expiry again for
max_age seconds, and bases these checks on the current time rather
than the time of the change.

A quick fix for the forward delay 0 case would be to skip the
topology change check if stp is disabled, but if I understand things
correctly, the expiry isn't right for non-zero cases either.


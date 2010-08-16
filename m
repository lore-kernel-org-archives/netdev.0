From: Brian Haley <brian.haley@hp.com>
Subject: Re: [iproute2] iproute2:  Fix 'addr flush secondary' logic.
Date: Mon, 16 Aug 2010 11:58:12 -0400
Message-ID: <4C696014.4080508@hp.com>
References: <1281547182-1252-1-git-send-email-greearb@candelatech.com> <4C630B0A.9010304@hp.com> <4C6328A8.4070703@candelatech.com> <4C6444EA.1070704@hp.com> <4C65A1CD.5090800@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:6871 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517Ab0HPP6P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 11:58:15 -0400
In-Reply-To: <4C65A1CD.5090800@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/13/2010 03:49 PM, Ben Greear wrote:
> Attached is an updated patch to fix some of the errors you
> mentioned.  It also fixes a bug when '-s -s' is used:  The old
> code modified the ifa flags, which made it not handle the check
> for primary v/s secondary correctly in the next filter.

Thanks for the update, nitpicking comments below.

BTW, promote_secondaries was the reason for some of my testing
issues as I don't usually run with that enabled.

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 5f0789c..51b59b4 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c

> @@ -571,40 +572,41 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
> 				    abuf, sizeof(abuf)));
> 	}
> 	fprintf(fp, "scope %s ", rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
> +	ifa_flags = ifa->ifa_flags;
> 	if (ifa->ifa_flags&IFA_F_SECONDARY) {

Maybe put a comment as to the reason, so someone doesn't change it
back in the future:

/* Use local copy of flags to not interfere with filtering code */

> @@ -848,6 +850,7 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
> 				exit(1);
> 			}
> 			if (filter.flushed == 0) {
> +			flush_done:
>  				if (show_stats) {
> 					if (round == 0)
> 						printf("Nothing to flush.\n");

Can you put "flush_done" at the beginning of the line?

> @@ -865,6 +868,13 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
> 				printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
> 				fflush(stdout);
> 			}
> +
> +			/* If we are flushing, and specifying primary, then we want to flush only a single round.
> +			 * Otherwise, we'll start flushing secondaries that were promoted to primaries
> +			 */
> +			if (!(filter.flags & IFA_F_SECONDARY) && (filter.flagmask & IFA_F_SECONDARY)) {
> +				goto flush_done;
> +			}

You don't need the {} here.  Also, the comment line-wraps since it's
> 80 chars.

Everything seems to work correctly in my limited testing otherwise, thanks.

Tested-by: Brian Haley <brian.haley@hp.com>

-Brian

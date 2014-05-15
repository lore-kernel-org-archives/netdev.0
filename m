From: Jay Vosburgh <jay.vosburgh@canonical.com>
Subject: Re: [PATCH iproute2] tc/netem: loss gemodel options fixes
Date: Thu, 15 May 2014 12:46:39 -0700
Message-ID: <11467.1400183199@localhost.localdomain>
References: <29682.1399754098@localhost.localdomain> <CAPh34mf4ahPyTDf-tEhsNKSFBL6GYjES9+TTvDjhMf2YLTr04Q@mail.gmail.com>
Cc: netdev@vger.kernel.org, netem@lists.linux-foundation.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:41201 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754628AbaEOTqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 15:46:46 -0400
In-reply-to: <CAPh34mf4ahPyTDf-tEhsNKSFBL6GYjES9+TTvDjhMf2YLTr04Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer <hagen@jauu.net> wrote:

>Stephen, tomorrow I will take a look at Jay's patches.

	Just to make it clear what I believe is incorrect with regards
to the h and 1-h part:

net/sched/sch_netem.c:
[...]
                /* 4-states and Gilbert-Elliot models */
                u32 a1; /* p13 for 4-states or p for GE */
                u32 a2; /* p31 for 4-states or r for GE */
                u32 a3; /* p32 for 4-states or h for GE */
                u32 a4; /* p14 for 4-states or 1-k for GE */
[...]

	Note that a3 is "h for GE" vs a4 is "1-k for GE". Also, in
the actual drop function:

static bool loss_gilb_ell(struct netem_sched_data *q)
[...]
        case GOOD_STATE:
[...]
                if (prandom_u32() < clg->a4)
                        return true;
                break;
        case BAD_STATE:
[...]
                if (prandom_u32() > clg->a3)
                        return true;
[...]

	The test for clg->a3 is inverted as compared to the test for
clg->a4.  Hence, the kernel is using "h," not "1-h," and therefore tc
should pass in the value for h instead of 1-h as it does currently.

	-J

>On May 10, 2014 10:35 PM, "Jay Vosburgh" <jay.vosburgh@canonical.com>
>wrote:
>
>    First, the default value for 1-k is documented as being 0, but is
>    currently being set to 1. (100%). This causes all packets to be
>    dropped
>    in the good state if 1-k is not explicitly specified. Fix this by
>    setting
>    the default to 0.
>    
>    Second, the 1-h option is parsed correctly, however, the kernel is
>    expecting "h", not 1-h. Fix this by inverting the "1-h" percentage
>    before
>    sending to and after receiving from the kernel. This does change the
>    behavior, but makes it consistent with the netem documentation and the
>    literature on the Gilbert-Elliot model, which refer to "1-h" and
>    "1-k,"
>    not "h" or "k" directly.
>    
>    Last, fix a minor formatting issue for the options reporting.
>    
>    Signed-off-by: Jay Vosburgh <jay.vosburgh@canonical.com>
>    ---
>    tc/q_netem.c | 11 ++++++++---
>    1 file changed, 8 insertions(+), 3 deletions(-)
>    
>    diff --git a/tc/q_netem.c b/tc/q_netem.c
>    index c83e301..8abe07f 100644
>    --- a/tc/q_netem.c
>    +++ b/tc/q_netem.c
>    @@ -307,7 +307,7 @@ static int netem_parse_opt(struct qdisc_util *qu,
>    int argc, char **argv,
>    /* set defaults */
>    set_percent(&gemodel.r, 1.);
>    set_percent(&gemodel.h, 0);
>    - set_percent(&gemodel.k1, 1.);
>    + set_percent(&gemodel.k1, 0);
>    loss_type = NETEM_LOSS_GE;
>    
>    if (!NEXT_IS_NUMBER())
>    @@ -325,6 +325,10 @@ static int netem_parse_opt(struct qdisc_util *qu,
>    int argc, char **argv,
>    explain1("loss gemodel h");
>    return -1;
>    }
>    + /* netem option is "1-h" but kernel
>    + * expects "h".
>    + */
>    + gemodel.h = max_percent_value - gemodel.h;
>    
>    if (!NEXT_IS_NUMBER())
>    continue;
>    @@ -625,10 +629,11 @@ static int netem_print_opt(struct qdisc_util
>    *qu, FILE *f, struct rtattr *opt)
>    }
>    
>    if (gemodel) {
>    - fprintf(f, "loss gemodel p %s",
>    + fprintf(f, " loss gemodel p %s",
>    sprint_percent(gemodel->p, b1));
>    fprintf(f, " r %s", sprint_percent(gemodel->r, b1));
>    - fprintf(f, " 1-h %s", sprint_percent(gemodel->h, b1));
>    + fprintf(f, " 1-h %s", sprint_percent(max_percent_value -
>    + gemodel->h, b1));
>    fprintf(f, " 1-k %s", sprint_percent(gemodel->k1, b1));
>    }
>    
>    --
>    1.8.3.2

---
	-Jay Vosburgh, jay.vosburgh@canonical.com

From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: Re: [PATCH iproute2 v2] bridge/link: add learning_sync policy flag
Date: Fri, 2 Jan 2015 22:44:37 +0530
Message-ID: <CA+CtxLS7x8zKQ-9xwjoH3=pidkXS9s5b2+K_VO4eDHJTWo5tYQ@mail.gmail.com>
References: <1419884407-21998-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
	jiri@resnulli.us, roopa@cumulusnetworks.com
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:48156 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751818AbbABRWV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 12:22:21 -0500
Received: by mail-wg0-f47.google.com with SMTP id n12so24157921wgh.6
        for <netdev@vger.kernel.org>; Fri, 02 Jan 2015 09:22:19 -0800 (PST)
In-Reply-To: <1419884407-21998-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


> +.BR "learning_sync on " or " learning_sync off "
> +Controls whether a given port will sync MAC addresses learned on device port to
> +bridge FDB.
> +

For the FDB entries synced from device port to bridge FDB, can the
device port also mention that it will take care of aging the synced
entries? I am thinking of a use case where the port supports hardware
learning and hardware aging?

Regards,
Siva.



On Tue, Dec 30, 2014 at 1:50 AM,  <sfeldma@gmail.com> wrote:
> From: Scott Feldman <sfeldma@gmail.com>
>
> v2:
>
> Resending now that the dust has cleared in 3.18 on "self" vs. hwmode debate for
> brport settings.  learning_sync is now set/cleared using "self" qualifier on
> brport.
>
> v1:
>
> Add 'learned_sync' flag to turn on/off syncing of learned MAC addresses from
> offload device to bridge's FDB.   Flag is be set/cleared on offload device port
> using "self" qualifier:
>
>   $ sudo bridge link set dev swp1 learning_sync on self
>
>   $ bridge -d link show dev swp1
>   2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0 state forwarding priority 32 cost 2
>       hairpin off guard off root_block off fastleave off learning off flood off
>   2: swp1 state UNKNOWN : <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 master br0
>       learning on learning_sync on
>
> Adds new IFLA_BRPORT_LEARNED_SYNCED attribute for IFLA_PROTINFO on the SELF
> brport.
>
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> ---
>  bridge/link.c     |   12 ++++++++++++
>  man/man8/bridge.8 |    6 ++++++
>  2 files changed, 18 insertions(+)
>
> diff --git a/bridge/link.c b/bridge/link.c
> index 3f77aab..c8555f8 100644
> --- a/bridge/link.c
> +++ b/bridge/link.c
> @@ -188,6 +188,9 @@ int print_linkinfo(const struct sockaddr_nl *who,
>                                 if (prtb[IFLA_BRPORT_LEARNING])
>                                         print_onoff(fp, "learning",
>                                                     rta_getattr_u8(prtb[IFLA_BRPORT_LEARNING]));
> +                               if (prtb[IFLA_BRPORT_LEARNING_SYNC])
> +                                       print_onoff(fp, "learning_sync",
> +                                                   rta_getattr_u8(prtb[IFLA_BRPORT_LEARNING_SYNC]));
>                                 if (prtb[IFLA_BRPORT_UNICAST_FLOOD])
>                                         print_onoff(fp, "flood",
>                                                     rta_getattr_u8(prtb[IFLA_BRPORT_UNICAST_FLOOD]));
> @@ -221,6 +224,7 @@ static void usage(void)
>         fprintf(stderr, "                               [ fastleave {on | off} ]\n");
>         fprintf(stderr, "                               [ root_block {on | off} ]\n");
>         fprintf(stderr, "                               [ learning {on | off} ]\n");
> +       fprintf(stderr, "                               [ learning_sync {on | off} ]\n");
>         fprintf(stderr, "                               [ flood {on | off} ]\n");
>         fprintf(stderr, "                               [ hwmode {vepa | veb} ]\n");
>         fprintf(stderr, "       bridge link show [dev DEV]\n");
> @@ -252,6 +256,7 @@ static int brlink_modify(int argc, char **argv)
>         } req;
>         char *d = NULL;
>         __s8 learning = -1;
> +       __s8 learning_sync = -1;
>         __s8 flood = -1;
>         __s8 hairpin = -1;
>         __s8 bpdu_guard = -1;
> @@ -295,6 +300,10 @@ static int brlink_modify(int argc, char **argv)
>                         NEXT_ARG();
>                         if (!on_off("learning", &learning, *argv))
>                                 exit(-1);
> +               } else if (strcmp(*argv, "learning_sync") == 0) {
> +                       NEXT_ARG();
> +                       if (!on_off("learning_sync", &learning_sync, *argv))
> +                               exit(-1);
>                 } else if (strcmp(*argv, "flood") == 0) {
>                         NEXT_ARG();
>                         if (!on_off("flood", &flood, *argv))
> @@ -359,6 +368,9 @@ static int brlink_modify(int argc, char **argv)
>                 addattr8(&req.n, sizeof(req), IFLA_BRPORT_UNICAST_FLOOD, flood);
>         if (learning >= 0)
>                 addattr8(&req.n, sizeof(req), IFLA_BRPORT_LEARNING, learning);
> +       if (learning_sync >= 0)
> +               addattr8(&req.n, sizeof(req), IFLA_BRPORT_LEARNING_SYNC,
> +                        learning_sync);
>
>         if (cost > 0)
>                 addattr32(&req.n, sizeof(req), IFLA_BRPORT_COST, cost);
> diff --git a/man/man8/bridge.8 b/man/man8/bridge.8
> index cb3fb46..e344db2 100644
> --- a/man/man8/bridge.8
> +++ b/man/man8/bridge.8
> @@ -38,6 +38,7 @@ bridge \- show / manipulate bridge addresses and devices
>  .BR fastleave " { " on " | " off " } ] [ "
>  .BR root_block " { " on " | " off " } ] [ "
>  .BR learning " { " on " | " off " } ] [ "
> +.BR learning_sync " { " on " | " off " } ] [ "
>  .BR flood " { " on " | " off " } ] [ "
>  .BR hwmode " { " vepa " | " veb " } ] "
>
> @@ -263,6 +264,11 @@ not.  If learning if off, the bridge will end up flooding any traffic for which
>  it has no FDB entry.  By default this flag is on.
>
>  .TP
> +.BR "learning_sync on " or " learning_sync off "
> +Controls whether a given port will sync MAC addresses learned on device port to
> +bridge FDB.
> +
> +.TP
>  .BR "flooding on " or " flooding off "
>  Controls whether a given port will flood unicast traffic for which there is no FDB entry.  By default this flag is on.
>
> --
> 1.7.10.4
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

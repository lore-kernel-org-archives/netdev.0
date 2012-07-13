From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [PATCH] iproute2: Fix memory hog of ip batched command.
Date: Fri, 13 Jul 2012 12:42:49 -0700
Message-ID: <CALnjE+oxLUyGy_8Ov=UBA_0fnqiMSRJmQtUJ8aDo_m=rVdYmvg@mail.gmail.com>
References: <1342142466-28270-1-git-send-email-pshelar@nicira.com>
	<20120713095342.09324ebc@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, jpettit@nicira.com, jesse@nicira.com
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog119.obsmtp.com ([74.125.149.246]:50711 "HELO
	na3sys009aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753190Ab2GMTmu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2012 15:42:50 -0400
Received: by mail-vc0-f170.google.com with SMTP id gb22so2322955vcb.15
        for <netdev@vger.kernel.org>; Fri, 13 Jul 2012 12:42:49 -0700 (PDT)
In-Reply-To: <20120713095342.09324ebc@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 13, 2012 at 9:53 AM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Thu, 12 Jul 2012 18:21:06 -0700
> Pravin B Shelar <pshelar@nicira.com> wrote:
>
>> ipaddr_list_or_flush() builds list of all device at start of
>> every flush or list operation, but does not free memory at end.
>> This can hog lot of memory for large batched command.
>> Following patch fixes it.
>>
>> Reported-by: Justin Pettit <jpettit@nicira.com>
>> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
>
> What about this instead? It also has a couple of other changes:
>   1. stdout isn't flushed on each print only at end
>   2. address list does not need to be fetched when doing flush
>
sounds good.

> It comes up clean under valgrind.
>
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index 5e03d1e..8870ae8 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -768,11 +768,145 @@ static int store_nlmsg(const struct sockaddr_nl *who, struct nlmsghdr *n,
>         return 0;
>  }
>
> +static void free_nlmsg_chain(struct nlmsg_chain *info)
> +{
> +       struct nlmsg_list *l, *n;
> +
> +       for (l = info->head; l; l = n) {
> +               n = l->next;
> +               free(l);
> +       }
> +}
> +
> +static void ipaddr_filter(struct nlmsg_chain *linfo, struct nlmsg_chain *ainfo)
> +{
> +       struct nlmsg_list *l, **lp;
> +
> +       lp = &linfo->head;
> +       while ( (l = *lp) != NULL) {
> +               int ok = 0;
> +               struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
> +               struct nlmsg_list *a;
> +
> +               for (a = ainfo->head; a; a = a->next) {
> +                       struct nlmsghdr *n = &a->h;
> +                       struct ifaddrmsg *ifa = NLMSG_DATA(n);
> +
> +                       if (ifa->ifa_index != ifi->ifi_index ||
> +                           (filter.family && filter.family != ifa->ifa_family))
> +                               continue;
> +                       if ((filter.scope^ifa->ifa_scope)&filter.scopemask)
> +                               continue;
> +                       if ((filter.flags^ifa->ifa_flags)&filter.flagmask)
> +                               continue;
> +                       if (filter.pfx.family || filter.label) {
> +                               struct rtattr *tb[IFA_MAX+1];
> +                               parse_rtattr(tb, IFA_MAX, IFA_RTA(ifa), IFA_PAYLOAD(n));
> +                               if (!tb[IFA_LOCAL])
> +                                       tb[IFA_LOCAL] = tb[IFA_ADDRESS];
> +
> +                               if (filter.pfx.family && tb[IFA_LOCAL]) {
> +                                       inet_prefix dst;
> +                                       memset(&dst, 0, sizeof(dst));
> +                                       dst.family = ifa->ifa_family;
> +                                       memcpy(&dst.data, RTA_DATA(tb[IFA_LOCAL]), RTA_PAYLOAD(tb[IFA_LOCAL]));
> +                                       if (inet_addr_match(&dst, &filter.pfx, filter.pfx.bitlen))
> +                                               continue;
> +                               }
> +                               if (filter.label) {
> +                                       SPRINT_BUF(b1);
> +                                       const char *label;
> +                                       if (tb[IFA_LABEL])
> +                                               label = RTA_DATA(tb[IFA_LABEL]);
> +                                       else
> +                                               label = ll_idx_n2a(ifa->ifa_index, b1);
> +                                       if (fnmatch(filter.label, label, 0) != 0)
> +                                               continue;
> +                               }
> +                       }
> +
> +                       ok = 1;
> +                       break;
> +               }
> +               if (!ok) {
> +                       *lp = l->next;
> +                       free(l);
> +               } else
> +                       lp = &l->next;
> +       }
> +}
> +
> +static int ipaddr_flush(void)
> +{
> +       int round = 0;
> +       char flushb[4096-512];
> +
> +       filter.flushb = flushb;
> +       filter.flushp = 0;
> +       filter.flushe = sizeof(flushb);
> +
> +       while ((max_flush_loops == 0) || (round < max_flush_loops)) {
> +               const struct rtnl_dump_filter_arg a[3] = {
> +                       {
> +                               .filter = print_addrinfo_secondary,
> +                               .arg1 = stdout,
> +                       },
> +                       {
> +                               .filter = print_addrinfo_primary,
> +                               .arg1 = stdout,
> +                       },
> +                       {
> +                               .filter = NULL,
> +                               .arg1 = NULL,
> +                       },
> +               };
> +               if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
> +                       perror("Cannot send dump request");
> +                       exit(1);
> +               }
> +               filter.flushed = 0;
> +               if (rtnl_dump_filter_l(&rth, a) < 0) {
> +                       fprintf(stderr, "Flush terminated\n");
> +                       exit(1);
> +               }
> +               if (filter.flushed == 0) {
> + flush_done:
> +                       if (show_stats) {
> +                               if (round == 0)
> +                                       printf("Nothing to flush.\n");
> +                               else
> +                                       printf("*** Flush is complete after %d round%s ***\n", round, round>1?"s":"");
> +                       }
> +                       fflush(stdout);
> +                       return 0;
> +               }
> +               round++;
> +               if (flush_update() < 0)
> +                       return 1;
> +
> +               if (show_stats) {
> +                       printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
> +                       fflush(stdout);
> +               }
> +
> +               /* If we are flushing, and specifying primary, then we
> +                * want to flush only a single round.  Otherwise, we'll
> +                * start flushing secondaries that were promoted to
> +                * primaries.
> +                */
> +               if (!(filter.flags & IFA_F_SECONDARY) && (filter.flagmask & IFA_F_SECONDARY))
> +                       goto flush_done;
> +       }
> +       fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", max_flush_loops);
> +       fflush(stderr);
> +       return 1;
> +}
> +
>  static int ipaddr_list_or_flush(int argc, char **argv, int flush)
>  {
>         struct nlmsg_chain linfo = { NULL, NULL};
>         struct nlmsg_chain ainfo = { NULL, NULL};
> -       struct nlmsg_list *l, *n;
> +       struct nlmsg_list *l;
>         char *filter_dev = NULL;
>         int no_link = 0;
>
> @@ -863,16 +997,6 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
>                 argv++; argc--;
>         }
>
> -       if (rtnl_wilddump_request(&rth, preferred_family, RTM_GETLINK) < 0) {
> -               perror("Cannot send dump request");
> -               exit(1);
> -       }
> -
> -       if (rtnl_dump_filter(&rth, store_nlmsg, &linfo) < 0) {
> -               fprintf(stderr, "Dump terminated\n");
> -               exit(1);
> -       }
> -
>         if (filter_dev) {
>                 filter.ifindex = ll_name_to_index(filter_dev);
>                 if (filter.ifindex <= 0) {
> @@ -881,72 +1005,23 @@ static int ipaddr_list_or_flush(int argc, char **argv, int flush)
>                 }
>         }
>
> -       if (flush) {
> -               int round = 0;
> -               char flushb[4096-512];
> -
> -               filter.flushb = flushb;
> -               filter.flushp = 0;
> -               filter.flushe = sizeof(flushb);
> -
> -               while ((max_flush_loops == 0) || (round < max_flush_loops)) {
> -                       const struct rtnl_dump_filter_arg a[3] = {
> -                               {
> -                                       .filter = print_addrinfo_secondary,
> -                                       .arg1 = stdout,
> -                               },
> -                               {
> -                                       .filter = print_addrinfo_primary,
> -                                       .arg1 = stdout,
> -                               },
> -                               {
> -                                       .filter = NULL,
> -                                       .arg1 = NULL,
> -                               },
> -                       };
> -                       if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
> -                               perror("Cannot send dump request");
> -                               exit(1);
> -                       }
> -                       filter.flushed = 0;
> -                       if (rtnl_dump_filter_l(&rth, a) < 0) {
> -                               fprintf(stderr, "Flush terminated\n");
> -                               exit(1);
> -                       }
> -                       if (filter.flushed == 0) {
> -flush_done:
> -                               if (show_stats) {
> -                                       if (round == 0)
> -                                               printf("Nothing to flush.\n");
> -                                       else
> -                                               printf("*** Flush is complete after %d round%s ***\n", round, round>1?"s":"");
> -                               }
> -                               fflush(stdout);
> -                               return 0;
> -                       }
> -                       round++;
> -                       if (flush_update() < 0)
> -                               return 1;
> +       if (flush)
> +               return ipaddr_flush();
>
> -                       if (show_stats) {
> -                               printf("\n*** Round %d, deleting %d addresses ***\n", round, filter.flushed);
> -                               fflush(stdout);
> -                       }
> +       if (rtnl_wilddump_request(&rth, preferred_family, RTM_GETLINK) < 0) {
> +               perror("Cannot send dump request");
> +               exit(1);
> +       }
>
> -                       /* If we are flushing, and specifying primary, then we
> -                        * want to flush only a single round.  Otherwise, we'll
> -                        * start flushing secondaries that were promoted to
> -                        * primaries.
> -                        */
> -                       if (!(filter.flags & IFA_F_SECONDARY) && (filter.flagmask & IFA_F_SECONDARY))
> -                               goto flush_done;
> -               }
> -               fprintf(stderr, "*** Flush remains incomplete after %d rounds. ***\n", max_flush_loops);
> -               fflush(stderr);
> -               return 1;
> +       if (rtnl_dump_filter(&rth, store_nlmsg, &linfo) < 0) {
> +               fprintf(stderr, "Dump terminated\n");
> +               exit(1);
>         }
>
> -       if (filter.family != AF_PACKET) {
> +       if (filter.family && filter.family != AF_PACKET) {
> +               if (filter.oneline)
> +                       no_link = 1;
> +
>                 if (rtnl_wilddump_request(&rth, filter.family, RTM_GETADDR) < 0) {
>                         perror("Cannot send dump request");
>                         exit(1);
> @@ -956,80 +1031,24 @@ flush_done:
>                         fprintf(stderr, "Dump terminated\n");
>                         exit(1);
>                 }
> -       }
> -
> -
> -       if (filter.family && filter.family != AF_PACKET) {
> -               struct nlmsg_list **lp;
> -               lp = &linfo.head;
> -
> -               if (filter.oneline)
> -                       no_link = 1;
>
> -               while ((l=*lp)!=NULL) {
> -                       int ok = 0;
> -                       struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
> -                       struct nlmsg_list *a;
> -
> -                       for (a = ainfo.head; a; a = a->next) {
> -                               struct nlmsghdr *n = &a->h;
> -                               struct ifaddrmsg *ifa = NLMSG_DATA(n);
> -
> -                               if (ifa->ifa_index != ifi->ifi_index ||
> -                                   (filter.family && filter.family != ifa->ifa_family))
> -                                       continue;
> -                               if ((filter.scope^ifa->ifa_scope)&filter.scopemask)
> -                                       continue;
> -                               if ((filter.flags^ifa->ifa_flags)&filter.flagmask)
> -                                       continue;
> -                               if (filter.pfx.family || filter.label) {
> -                                       struct rtattr *tb[IFA_MAX+1];
> -                                       parse_rtattr(tb, IFA_MAX, IFA_RTA(ifa), IFA_PAYLOAD(n));
> -                                       if (!tb[IFA_LOCAL])
> -                                               tb[IFA_LOCAL] = tb[IFA_ADDRESS];
> -
> -                                       if (filter.pfx.family && tb[IFA_LOCAL]) {
> -                                               inet_prefix dst;
> -                                               memset(&dst, 0, sizeof(dst));
> -                                               dst.family = ifa->ifa_family;
> -                                               memcpy(&dst.data, RTA_DATA(tb[IFA_LOCAL]), RTA_PAYLOAD(tb[IFA_LOCAL]));
> -                                               if (inet_addr_match(&dst, &filter.pfx, filter.pfx.bitlen))
> -                                                       continue;
> -                                       }
> -                                       if (filter.label) {
> -                                               SPRINT_BUF(b1);
> -                                               const char *label;
> -                                               if (tb[IFA_LABEL])
> -                                                       label = RTA_DATA(tb[IFA_LABEL]);
> -                                               else
> -                                                       label = ll_idx_n2a(ifa->ifa_index, b1);
> -                                               if (fnmatch(filter.label, label, 0) != 0)
> -                                                       continue;
> -                                       }
> -                               }
> -
> -                               ok = 1;
> -                               break;
> -                       }
> -                       if (!ok) {
> -                               *lp = l->next;
> -                               free(l);
> -                       } else
> -                               lp = &l->next;
> -               }
> +               ipaddr_filter(&linfo, &ainfo);
>         }
>
> -       for (l = linfo.head; l; l = n) {
> -               n = l->next;
> -               if (no_link || print_linkinfo(NULL, &l->h, stdout) == 0) {
> -                       struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
> -                       if (filter.family != AF_PACKET)
> -                               print_selected_addrinfo(ifi->ifi_index, ainfo.head, stdout);
> +       if (!no_link) {
> +               for (l = linfo.head; l; l = l->next) {
> +                       if (print_linkinfo(NULL, &l->h, stdout) == 0) {
> +                               struct ifinfomsg *ifi = NLMSG_DATA(&l->h);
> +                               if (filter.family != AF_PACKET)
> +                                       print_selected_addrinfo(ifi->ifi_index, ainfo.head, stdout);
> +                       }
>                 }
I am not sure why you have changed no_link check for printing address.

otherwise looks good.

>                 fflush(stdout);
> -               free(l);
>         }
>
> +       free_nlmsg_chain(&ainfo);
> +       free_nlmsg_chain(&linfo);
> +
>         return 0;
>  }
>
>

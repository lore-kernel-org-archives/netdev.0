From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH] Prefix List patch against 2.5.70
Date: Mon, 2 Jun 2003 15:02:03 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF0DFD7FB1.3567B088-ON88256D39.00724E19@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Cc: krkumar@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru,
   yoshfuji@linux-ipv6.org, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki /  =?ISO-2022-JP?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





On the "location of the data" issue, I have some comment.

The users of prefix list data don't know the prefix or the prefix length;
they know the interface index, and need to get the prefixes.

The data is fundamentally per-interface, and the routing table is
per-destination. So, adding the prefixes to the routing table doesn't seem
like the best choice because everything that currently uses the routing
table will have to skip over these extra entries (which they'll never be
interested in) and the users of the prefix data will have to skip over all
existing routing table entries (which they're never interested in).

Routes and prefixes are independent of each other, so throwing them in the
same table to me seems like it only creates work to skip entries that
aren't related, and because the users of the prefix data don't have the key
needed for a fast look-up in the routing table, prefix users in particular
have to skip through everything currently in the routing table, linearly,
with no benefit at all for being there.

I also see no relation between prefix list data and the FIB; current users
are completely independent from prefix list users, and it appears to only
slow both of them down. The prefix data is always looked-up by interface
index, so I think it really belongs in the inet6 per-interface structure,
unless I'm missing something. What benefits are there for lumping this with
existing data structures that aren't per-interface, or keyed per-interface?

                              +-DLS


YOSHIFUJI Hideaki / 吉藤英明  <yoshfuji@linux-ipv6.org>@vger.kernel.org on
05/30/2003 07:02:49 PM

Sent by:    linux-net-owner@vger.kernel.org


To:    krkumar@us.ltcfwd.linux.ibm.com
cc:    davem@redhat.com, kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
       netdev@oss.sgi.com, linux-net@vger.kernel.org
Subject:    Re: [PATCH] Prefix List patch against 2.5.70



In article <3ED80230.2030508@us.ibm.com> (at Fri, 30 May 2003 18:15:28
-0700), Krishna Kumar <krkumar@us.ibm.com> says:

> +/* prefix list returned to user space in this structure */
> +struct plist_user_info {
          ^ip6 or ipv6 or so.
> +   char name[IFNAMSIZ];          /* interface name */
        ~~~~~~~~~~~~~~~~~~~duplicate information.
> +   int ifindex;                  /* interface index */
> +   int nprefixes;                /* number of elements in 'prefix' */
> +   struct var_plist_user_info {  /* multiple elements */
> +         char flags[3];          /* router advertised flags */
                     ~~~~~~~~this is not good interface.
> +         int plen;         /* prefix length */
> +         __u32 valid;            /* valid lifetime */
> +         struct in6_addr ra_addr;/* advertising router */
> +         struct in6_addr prefix; /* prefix */
> +   } plist_vars[0];
> +};
> +
>   extern void               addrconf_init(void);
>   extern void               addrconf_cleanup(void);
>

:

I think we should use 1 fixed-length message per prefix,
instead of variable length message.


> +               pinfo->plist_vars[count].plen = p_el->pinfo.prefix_len;
> +               pinfo->plist_vars[count].valid = p_el->pinfo.valid -
> +                     (jiffies - p_el->timestamp)/HZ;
> +               if ((p_el->ra_flags & (ND_RA_FLAG_MANAGED |
> +                   ND_RA_FLAG_OTHER))
> +                   == (ND_RA_FLAG_MANAGED|ND_RA_FLAG_OTHER))
> +                     strcpy(pinfo->plist_vars[count].flags, "MO");
> +               else if (p_el->ra_flags & ND_RA_FLAG_MANAGED)
> +                     strcpy(pinfo->plist_vars[count].flags, "M");
> +               else if (p_el->ra_flags & ND_RA_FLAG_OTHER)
> +                     strcpy(pinfo->plist_vars[count].flags, "O");
> +               else
> +                     strcpy(pinfo->plist_vars[count].flags, "-");
> +               ipv6_addr_copy(&pinfo->plist_vars[count].ra_addr,
> +                   &p_el->ra_addr);
> +               for (i = 0; i < 8; i++)
> +                     pinfo->plist_vars[count].ra_addr.s6_addr16[i] =
> +
__constant_ntohs(pinfo->plist_vars[count].ra_addr.s6_addr16[i]);
> +               ipv6_addr_copy(&pinfo->plist_vars[count].prefix,
> +                   &p_el->pinfo.prefix);
> +               for (i = 0; i < p_el->pinfo.prefix_len/16; i++)
> +                     pinfo->plist_vars[count].prefix.s6_addr16[i] =
> +
__constant_ntohs(pinfo->plist_vars[count].prefix.s6_addr16[i]);

Absoletely nasty.
- don't use charaters to represent flags; use real flags.
- use network-byte order.


> +static int prefix_list_proc_dump(char *buffer, char **start, off_t
offset,
> +                  int length)
> +{
:

Please use seq_file.


Again, what I proposed was to store prefix information on fib with
some flags to represent advertised by routers and give user-space
the RA information using new rtattr (RTA_RA6INFO or something like that).

struct rta_ra6info {
     u32 rta_ra6flags;
};

--
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA


-
To unsubscribe from this list: send the line "unsubscribe linux-net" in
the body of a message to majordomo@vger.kernel.org
 More majordomo info at  http://vger.kernel.org/majordomo-info.html

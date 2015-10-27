From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v7 05/10] ss: replaced old output with new generic output
 mechanisms
Date: Tue, 27 Oct 2015 14:04:56 +0100
Message-ID: <20151027130456.GD26876@orbit.nwl.cc>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-6-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:34594 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753947AbbJ0NE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 09:04:59 -0400
Content-Disposition: inline
In-Reply-To: <1441913708-15532-6-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 09:35:03PM +0200, Matthias Tafelmeier wrote:
> This patch just adds the -j and --json flag to ss. Also it ensures pr=
oper
> stats components bracketization =E2=80=93 that goes for ex. TCP, UDP,=
 NETLINK etc.
>=20
> Moreover, this patch prevents human readable headers to be printed.
>=20
> Most importantly, with this patch, the new prepared interface to the
> generic output handlers is used to replace the accustomed output
> logic.
>=20
> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
> Suggested-by: Hagen Paul Pfeifer <hagen@jauu.net>
> ---
>  misc/ss.c | 487 ++++++++++++++++++++++++++++++++++------------------=
----------
>  1 file changed, 266 insertions(+), 221 deletions(-)
>=20
> diff --git a/misc/ss.c b/misc/ss.c
> index e7ea041..7a1b6eb 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -26,6 +26,7 @@
>  #include <fnmatch.h>
>  #include <getopt.h>
>  #include <stdbool.h>
> +#include <json_writer.h>
> =20
>  #include "ss_types.h"
>  #include "utils.h"
> @@ -34,6 +35,9 @@
>  #include "libnetlink.h"
>  #include "namespace.h"
>  #include "SNAPSHOT.h"
> +#include "ss_out_fmt.h"
> +#include "ss_json_fmt.h"
> +#include "ss_types.h"
> =20
>  #include <linux/tcp.h>
>  #include <linux/sock_diag.h>
> @@ -101,6 +105,7 @@ int show_sock_ctx =3D 0;
>  /* If show_users & show_proc_ctx only do user_ent_hash_build() once =
*/
>  int user_ent_hash_build_init =3D 0;
>  int follow_events =3D 0;
> +int json_output =3D 0;
> =20
>  int netid_width;
>  int state_width;
> @@ -109,11 +114,14 @@ int addr_width;
>  int serv_width;
>  int screen_width;
> =20
> +enum out_fmt_type fmt_type =3D FMT_HR;
> +
>  static const char *TCP_PROTO =3D "tcp";
>  static const char *UDP_PROTO =3D "udp";
>  static const char *RAW_PROTO =3D "raw";
>  static const char *dg_proto =3D NULL;
> =20
> +json_writer_t *json_wr;

Not sure if doable, but IMHO this should be hidden in ss_json_fmt.c.

>  #define PACKET_DBM ((1<<PACKET_DG_DB)|(1<<PACKET_R_DB))
>  #define UNIX_DBM ((1<<UNIX_DG_DB)|(1<<UNIX_ST_DB)|(1<<UNIX_SQ_DB))
> @@ -716,7 +724,6 @@ static int is_ephemeral(int port)
>  	return (port >=3D ip_local_port_min && port<=3D ip_local_port_max);
>  }
> =20
> -

Export changes like this one into a dedicated patch at the start of the
series?

>  static const char *__resolve_service(int port)
>  {
>  	struct scache *c;
> @@ -790,7 +797,8 @@ do_numeric:
>  	return buf;
>  }
> =20
> -static void inet_addr_print(const inet_prefix *a, int port, unsigned=
 int ifindex)
> +static void inet_addr_print(const inet_prefix *a, int port,
> +			unsigned int ifindex, char *peer_kind)
>  {
>  	char buf[1024];
>  	const char *ap =3D buf;
> @@ -818,8 +826,8 @@ static void inet_addr_print(const inet_prefix *a,=
 int port, unsigned int ifindex
>  		est_len -=3D strlen(ifname) + 1;  /* +1 for percent char */
>  	}
> =20
> -	sock_addr_print_width(est_len, ap, ":", serv_width, resolve_service=
(port),
> -			ifname);
> +	sock_addr_fmt(ap, est_len, ":", serv_width, resolve_service(port),
> +			ifname, peer_kind);
>  }
> =20
>  static int inet2_addr_match(const inet_prefix *a, const inet_prefix =
*p,
> @@ -1351,21 +1359,29 @@ static void inet_stats_print(struct sockstat =
*s, int protocol)
>  {
>  	char *buf =3D NULL;
> =20
> -	sock_state_print(s, proto_name(protocol));
> +	sock_state_fmt(s, sstate_name, proto_name(protocol),
> +				netid_width, state_width);
> =20
> -	inet_addr_print(&s->local, s->lport, s->iface);
> -	inet_addr_print(&s->remote, s->rport, 0);
> +	if (json_output) {
> +		jsonw_name(json_wr, "peers");
> +		jsonw_start_object(json_wr);
> +	}

How about an additional callback:

	fmt_new_object("peers");

The hr variant will be a no op, the json variant uses it's private (see
above) json_wr object.

> +	inet_addr_print(&s->local, s->lport, s->iface, "local");
> +	inet_addr_print(&s->remote, s->rport, 0, "remote");
> +	if (json_output)
> +		jsonw_end_object(json_wr);
> =20
>  	if (show_proc_ctx || show_sock_ctx) {
>  		if (find_entry(s->ino, &buf,
> -				(show_proc_ctx & show_sock_ctx) ?
> -				PROC_SOCK_CTX : PROC_CTX) > 0) {
> -			printf(" users:(%s)", buf);
> +			       (show_proc_ctx & show_sock_ctx) ?
> +			       PROC_SOCK_CTX : PROC_CTX) > 0) {
> +			sock_users_fmt(buf);
>  			free(buf);
>  		}
>  	} else if (show_users) {
>  		if (find_entry(s->ino, &buf, USERS) > 0) {
> -			printf(" users:(%s)", buf);
> +			sock_users_fmt(buf);
>  			free(buf);
>  		}
>  	}
> @@ -1469,16 +1485,16 @@ static int tcp_show_line(char *line, const st=
ruct filter *f, int family)
>  	inet_stats_print(&s.ss, IPPROTO_TCP);
> =20
>  	if (show_options)
> -		tcp_timer_print(&s);
> +		tcp_timer_fmt(&s);
> =20
>  	if (show_details) {
> -		sock_details_print(&s.ss);
> +		sock_details_fmt(&s.ss, GENERIC_DETAIL, 0, 0);
>  		if (opt[0])
> -			printf(" opt:\"%s\"", opt);
> +			opt_fmt(opt);
>  	}
> =20
>  	if (show_tcpinfo)
> -		tcp_stats_print(&s);
> +		tcp_stats_fmt(&s);
> =20
>  	printf("\n");
>  	return 0;
> @@ -1522,31 +1538,14 @@ static void print_skmeminfo(struct rtattr *tb=
[], int attrtype)
>  			const struct inet_diag_meminfo *minfo =3D
>  				RTA_DATA(tb[INET_DIAG_MEMINFO]);
> =20
> -			printf(" mem:(r%u,w%u,f%u,t%u)",
> -					minfo->idiag_rmem,
> -					minfo->idiag_wmem,
> -					minfo->idiag_fmem,
> -					minfo->idiag_tmem);
> +			mem_fmt(minfo);
>  		}
>  		return;
>  	}
> =20
>  	skmeminfo =3D RTA_DATA(tb[attrtype]);
> =20
> -	printf(" skmem:(r%u,rb%u,t%u,tb%u,f%u,w%u,o%u",
> -	       skmeminfo[SK_MEMINFO_RMEM_ALLOC],
> -	       skmeminfo[SK_MEMINFO_RCVBUF],
> -	       skmeminfo[SK_MEMINFO_WMEM_ALLOC],
> -	       skmeminfo[SK_MEMINFO_SNDBUF],
> -	       skmeminfo[SK_MEMINFO_FWD_ALLOC],
> -	       skmeminfo[SK_MEMINFO_WMEM_QUEUED],
> -	       skmeminfo[SK_MEMINFO_OPTMEM]);
> -
> -	if (RTA_PAYLOAD(tb[attrtype]) >=3D
> -		(SK_MEMINFO_BACKLOG + 1) * sizeof(__u32))
> -		printf(",bl%u", skmeminfo[SK_MEMINFO_BACKLOG]);
> -
> -	printf(")");
> +	skmem_fmt(skmeminfo, tb, attrtype);
>  }
> =20
>  #define TCPI_HAS_OPT(info, opt) !!(info->tcpi_options & (opt))
> @@ -1659,8 +1658,11 @@ static void tcp_show_info(const struct nlmsghd=
r *nlh, struct inet_diag_msg *r,
>  		s.bytes_received =3D info->tcpi_bytes_received;
>  		s.segs_out =3D info->tcpi_segs_out;
>  		s.segs_in =3D info->tcpi_segs_in;
> -		tcp_stats_print(&s);
> -		free(s.dctcp);
> +		tcp_stats_fmt(&s);
> +		if (s.dctcp)
> +			free(s.dctcp);
> +		if (s.cong_alg)
> +			free(s.cong_alg);
>  	}
>  }
> =20
> @@ -1684,6 +1686,8 @@ static int inet_show_sock(struct nlmsghdr *nlh,=
 struct filter *f, int protocol)
>  	s.iface		=3D r->id.idiag_if;
>  	s.sk		=3D cookie_sk_get(&r->id.idiag_cookie[0]);
> =20
> +	jsonw_start_object(json_wr);
> +
>  	if (s.local.family =3D=3D AF_INET) {
>  		s.local.bytelen =3D s.remote.bytelen =3D 4;
>  	} else {
> @@ -1707,29 +1711,27 @@ static int inet_show_sock(struct nlmsghdr *nl=
h, struct filter *f, int protocol)
>  		t.timer =3D r->idiag_timer;
>  		t.timeout =3D r->idiag_expires;
>  		t.retrans =3D r->idiag_retrans;
> -		tcp_timer_print(&t);
> +		tcp_timer_fmt(&t);
>  	}
> =20
>  	if (show_details) {
> -		sock_details_print(&s);
> -		if (s.local.family =3D=3D AF_INET6 && tb[INET_DIAG_SKV6ONLY]) {
> -			unsigned char v6only;
> -			v6only =3D *(__u8 *)RTA_DATA(tb[INET_DIAG_SKV6ONLY]);
> -			printf(" v6only:%u", v6only);
> -		}
> +		sock_details_fmt(&s, GENERIC_DETAIL, 0, 0);

Looks like v6only state got optimized out. At least I don't see it bein=
g
exported in the sock_details_fmt callbacks.

>  		if (tb[INET_DIAG_SHUTDOWN]) {
>  			unsigned char mask;
>  			mask =3D *(__u8 *)RTA_DATA(tb[INET_DIAG_SHUTDOWN]);
> -			printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
> +			sock_conn_fmt(mask);

While it is questionable in general whether json output should follow
this kind of symbolism, it appears that both callbacks do the same
INET_DIAG_SHUTDOWN value encoding. Unnecessary and error-prone code
duplication IMO. As a side-note, one could also implement
sock_conn_fmt() to accept a format-string, although that's maybe not
worth the effort.

>  		}
>  	}
> =20
>  	if (show_mem || show_tcpinfo) {
> -		printf("\n\t");

Hmm. Doesn't this change hr output? Not that it's not worth improving,
but I don't think it should be part of this series.

>  		tcp_show_info(nlh, r, tb);
>  	}
> =20
> -	printf("\n");
> +	if (json_output)
> +		jsonw_end_object(json_wr);
> +	else
> +		printf("\n");
> +
>  	return 0;
>  }
> =20
> @@ -2080,7 +2082,10 @@ static int dgram_show_line(char *line, const s=
truct filter *f, int family)
>  	inet_stats_print(&s, dg_proto =3D=3D UDP_PROTO ? IPPROTO_UDP : 0);
> =20
>  	if (show_details && opt[0])
> -		printf(" opt:\"%s\"", opt);
> +		opt_fmt(opt);
> +
> +	if (json_output)
> +		jsonw_end_object(json_wr);
> =20
>  	printf("\n");
>  	return 0;
> @@ -2257,27 +2262,39 @@ static void unix_stats_print(struct sockstat =
*list, struct filter *f)
>  				continue;
>  		}
> =20
> -		sock_state_print(s, unix_netid_name(s->type));
> +		sock_state_fmt(s, sstate_name,
> +			unix_netid_name(s->type), netid_width, state_width);
> =20
> -		sock_addr_print(s->name ?: "*", " ",
> -				int_to_str(s->lport, port_name), NULL);
> -		sock_addr_print(peer, " ", int_to_str(s->rport, port_name),
> -				NULL);
> +		if (json_output) {
> +			jsonw_name(json_wr, "peers");
> +			jsonw_start_object(json_wr);
> +		}
> +
> +		sock_addr_fmt(s->name ?: "*", addr_width,
> +			" ", serv_width,
> +			int_to_str(s->lport, port_name),
> +				NULL, "local");
> +		sock_addr_fmt(peer, addr_width, " ", serv_width,
> +				int_to_str(s->rport, port_name),
> +				NULL, "remote");
> +		if (json_output)
> +			jsonw_end_object(json_wr);
> =20
>  		if (show_proc_ctx || show_sock_ctx) {
>  			if (find_entry(s->ino, &ctx_buf,
> -					(show_proc_ctx & show_sock_ctx) ?
> -					PROC_SOCK_CTX : PROC_CTX) > 0) {
> -				printf(" users:(%s)", ctx_buf);
> +				       (show_proc_ctx & show_sock_ctx) ?
> +				       PROC_SOCK_CTX : PROC_CTX) > 0) {
> +				sock_users_fmt(ctx_buf);
>  				free(ctx_buf);
>  			}
>  		} else if (show_users) {
>  			if (find_entry(s->ino, &ctx_buf, USERS) > 0) {
> -				printf(" users:(%s)", ctx_buf);
> +				sock_users_fmt(ctx_buf);
>  				free(ctx_buf);
>  			}
>  		}
> -		printf("\n");
> +		if (!json_output)
> +			printf("\n");
>  	}
>  }
> =20
> @@ -2290,7 +2307,9 @@ static int unix_show_sock(const struct sockaddr=
_nl *addr, struct nlmsghdr *nlh,
>  	char name[128];
>  	struct sockstat stat =3D { .name =3D "*", .peer_name =3D "*" };
> =20
> -	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr*)(r+1),
> +	jsonw_start_object(json_wr);
> +
> +	parse_rtattr(tb, UNIX_DIAG_MAX, (struct rtattr *)(r + 1),

Yet another unrelated change. Although I surely repeat myself: Fixing u=
p
coding style is good, but complicating this patch with it is not. Might
go well along with empty line cleanup and other "meta" changes into an
initial patch.

>  		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
> =20
>  	stat.type  =3D r->udiag_type;
> @@ -2323,21 +2342,27 @@ static int unix_show_sock(const struct sockad=
dr_nl *addr, struct nlmsghdr *nlh,
>  		return 0;
> =20
>  	unix_stats_print(&stat, f);
> -
>  	if (show_mem) {
> -		printf("\t");
> +		if (!json_output)
> +			printf("\t");
>  		print_skmeminfo(tb, UNIX_DIAG_MEMINFO);

Can't you just move the tab printing into mem_hr_fmt()? (Maybe I miss
something here.)

>  	}
>  	if (show_details) {
>  		if (tb[UNIX_DIAG_SHUTDOWN]) {
>  			unsigned char mask;
>  			mask =3D *(__u8 *)RTA_DATA(tb[UNIX_DIAG_SHUTDOWN]);
> -			printf(" %c-%c", mask & 1 ? '-' : '<', mask & 2 ? '-' : '>');
> +			sock_conn_fmt(mask);
>  		}
>  	}
>  	if (show_mem || show_details)
> -		printf("\n");
> +		if (!json_output)
> +			printf("\n");
> +
> +	if (json_output)
> +		jsonw_end_object(json_wr);
> =20
> +	if (name)
> +		free(name);
>  	return 0;
>  }
> =20
> @@ -2479,7 +2504,8 @@ static int packet_stats_print(struct sockstat *=
s, const struct filter *f)
>  			return 1;
>  	}
> =20
> -	sock_state_print(s, s->type =3D=3D SOCK_RAW ? "p_raw" : "p_dgr");
> +	sock_state_fmt(s, sstate_name, s->type =3D=3D SOCK_RAW ? "p_raw" : =
"p_dgr",
> +					netid_width, state_width);
> =20
>  	if (s->prot =3D=3D 3)
>  		addr =3D "*";
> @@ -2491,25 +2517,37 @@ static int packet_stats_print(struct sockstat=
 *s, const struct filter *f)
>  	else
>  		port =3D xll_index_to_name(s->iface);
> =20
> -	sock_addr_print(addr, ":", port, NULL);
> -	sock_addr_print("", "*", "", NULL);
> +	if (json_output) {
> +		jsonw_name(json_wr, "peers");
> +		jsonw_start_object(json_wr);
> +	}
> +
> +	sock_addr_fmt(addr, addr_width, ":",
> +			serv_width, port,
> +			NULL, "local");
> +	sock_addr_fmt("", addr_width, "*",
> +			serv_width, "",
> +			NULL, "remote");

addr_width and serv_width belong to hr formatting only, json ignores
them altogether. Therefore hide them in hr output code.

> +	if (json_output)
> +		jsonw_end_object(json_wr);
> =20
>  	if (show_proc_ctx || show_sock_ctx) {
>  		if (find_entry(s->ino, &buf,
> -					(show_proc_ctx & show_sock_ctx) ?
> -					PROC_SOCK_CTX : PROC_CTX) > 0) {
> -			printf(" users:(%s)", buf);
> +			       (show_proc_ctx & show_sock_ctx) ?
> +			       PROC_SOCK_CTX : PROC_CTX) > 0) {
> +			sock_users_fmt(buf);

Yet another case of unrelated changes (indenting fixup), this time
combined with real changes. Hard to spot what's really going on here.

>  			free(buf);
>  		}
>  	} else if (show_users) {
>  		if (find_entry(s->ino, &buf, USERS) > 0) {
> -			printf(" users:(%s)", buf);
> +			sock_users_fmt(buf);
>  			free(buf);
>  		}
>  	}
> =20
>  	if (show_details)
> -		sock_details_print(s);
> +		sock_details_fmt(s, GENERIC_DETAIL, 0, 0);
> =20
>  	return 0;
>  }
> @@ -2526,7 +2564,9 @@ static int packet_show_sock(const struct sockad=
dr_nl *addr,
>  	uint32_t fanout =3D 0;
>  	bool has_fanout =3D false;
> =20
> -	parse_rtattr(tb, PACKET_DIAG_MAX, (struct rtattr*)(r+1),
> +	jsonw_start_object(json_wr);
> +
> +	parse_rtattr(tb, PACKET_DIAG_MAX, (struct rtattr *)(r + 1),
>  		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
> =20
>  	/* use /proc/net/packet if all info are not available */
> @@ -2566,60 +2606,9 @@ static int packet_show_sock(const struct socka=
ddr_nl *addr,
>  	if (packet_stats_print(&stat, f))
>  		return 0;
> =20
> -	if (show_details) {
> -		if (pinfo) {
> -			printf("\n\tver:%d", pinfo->pdi_version);
> -			printf(" cpy_thresh:%d", pinfo->pdi_copy_thresh);
> -			printf(" flags( ");
> -			if (pinfo->pdi_flags & PDI_RUNNING)
> -				printf("running");
> -			if (pinfo->pdi_flags & PDI_AUXDATA)
> -				printf(" auxdata");
> -			if (pinfo->pdi_flags & PDI_ORIGDEV)
> -				printf(" origdev");
> -			if (pinfo->pdi_flags & PDI_VNETHDR)
> -				printf(" vnethdr");
> -			if (pinfo->pdi_flags & PDI_LOSS)
> -				printf(" loss");
> -			if (!pinfo->pdi_flags)
> -				printf("0");
> -			printf(" )");
> -		}
> -		if (ring_rx) {
> -			printf("\n\tring_rx(");
> -			packet_show_ring(ring_rx);
> -			printf(")");
> -		}
> -		if (ring_tx) {
> -			printf("\n\tring_tx(");
> -			packet_show_ring(ring_tx);
> -			printf(")");
> -		}
> -		if (has_fanout) {
> -			uint16_t type =3D (fanout >> 16) & 0xffff;
> -
> -			printf("\n\tfanout(");
> -			printf("id:%d,", fanout & 0xffff);
> -			printf("type:");
> -
> -			if (type =3D=3D 0)
> -				printf("hash");
> -			else if (type =3D=3D 1)
> -				printf("lb");
> -			else if (type =3D=3D 2)
> -				printf("cpu");
> -			else if (type =3D=3D 3)
> -				printf("roll");
> -			else if (type =3D=3D 4)
> -				printf("random");
> -			else if (type =3D=3D 5)
> -				printf("qm");
> -			else
> -				printf("0x%x", type);
> -
> -			printf(")");
> -		}
> -	}
> +	if (show_details)
> +		packet_details_fmt(pinfo,
> +				ring_rx, ring_tx, fanout, has_fanout);
> =20
>  	if (show_bpf && tb[PACKET_DIAG_FILTER]) {
>  		struct sock_filter *fil =3D
> @@ -2627,15 +2616,15 @@ static int packet_show_sock(const struct sock=
addr_nl *addr,
>  		int num =3D RTA_PAYLOAD(tb[PACKET_DIAG_FILTER]) /
>  			  sizeof(struct sock_filter);
> =20
> -		printf("\n\tbpf filter (%d): ", num);
> -		while (num) {
> -			printf(" 0x%02x %u %u %u,",
> -			      fil->code, fil->jt, fil->jf, fil->k);
> -			num--;
> -			fil++;
> -		}
> +		bpf_filter_fmt(fil, num);
>  	}
> -	printf("\n");
> +
> +	if (json_output)
> +		jsonw_end_object(json_wr);
> +	else
> +		printf("\n");
> +
> +
>  	return 0;
>  }
> =20
> @@ -2713,6 +2702,7 @@ static int netlink_show_one(struct filter *f,
>  	SPRINT_BUF(prot_buf) =3D {};
>  	const char *prot_name;
>  	char procname[64] =3D {};
> +	char *rem =3D "remote";
> =20
>  	st.state =3D SS_CLOSE;
>  	st.rq	 =3D rq;
> @@ -2728,7 +2718,7 @@ static int netlink_show_one(struct filter *f,
>  			return 1;
>  	}
> =20
> -	sock_state_print(&st, "nl");
> +	sock_state_fmt(&st, sstate_name, "nl", netid_width, state_width);
> =20
>  	if (resolve_services)
>  		prot_name =3D nl_proto_n2a(prot, prot_buf, sizeof(prot_buf));
> @@ -2760,17 +2750,27 @@ static int netlink_show_one(struct filter *f,
>  		int_to_str(pid, procname);
>  	}
> =20
> -	sock_addr_print(prot_name, ":", procname, NULL);
> +	if (json_output) {
> +		jsonw_name(json_wr, "peers");
> +		jsonw_start_object(json_wr);
> +	}
> +
> +	sock_addr_fmt(prot_name, addr_width, ":", serv_width,
> +			procname, NULL, "local");
> =20
>  	if (state =3D=3D NETLINK_CONNECTED) {
>  		char dst_group_buf[30];
>  		char dst_pid_buf[30];
> -		sock_addr_print(int_to_str(dst_group, dst_group_buf), ":",
> -				int_to_str(dst_pid, dst_pid_buf), NULL);
> +		sock_addr_fmt(int_to_str(dst_group, dst_group_buf), addr_width,
> +				":", serv_width, int_to_str(dst_pid, dst_pid_buf),
> +				NULL, rem);
>  	} else {
> -		sock_addr_print("", "*", "", NULL);
> +		sock_addr_fmt("", addr_width, "*", serv_width, "", NULL, rem);
>  	}
> =20
> +	if (json_output)
> +		jsonw_end_object(json_wr);
> +
>  	char *pid_context =3D NULL;
>  	if (show_proc_ctx) {
>  		/* The pid value will either be:
> @@ -2784,16 +2784,11 @@ static int netlink_show_one(struct filter *f,
>  		else if (pid > 0)
>  			getpidcon(pid, &pid_context);
> =20
> -		if (pid_context !=3D NULL) {
> -			printf("proc_ctx=3D%-*s ", serv_width, pid_context);
> -			free(pid_context);
> -		} else {
> -			printf("proc_ctx=3D%-*s ", serv_width, "unavailable");
> -		}
> +		proc_fmt(serv_width, pid_context);
>  	}
> =20
>  	if (show_details) {
> -		printf(" sk=3D%llx cb=3D%llx groups=3D0x%08x", sk, cb, groups);
> +		sock_details_fmt(&st, NETLINK_DETAIL, groups, cb);
>  	}
>  	printf("\n");
> =20
> @@ -2809,7 +2804,9 @@ static int netlink_show_sock(const struct socka=
ddr_nl *addr,
>  	int rq =3D 0, wq =3D 0;
>  	unsigned long groups =3D 0;
> =20
> -	parse_rtattr(tb, NETLINK_DIAG_MAX, (struct rtattr*)(r+1),
> +	jsonw_start_object(json_wr);
> +
> +	parse_rtattr(tb, NETLINK_DIAG_MAX, (struct rtattr *)(r + 1),
>  		     nlh->nlmsg_len - NLMSG_LENGTH(sizeof(*r)));
> =20
>  	if (tb[NETLINK_DIAG_GROUPS] && RTA_PAYLOAD(tb[NETLINK_DIAG_GROUPS])=
)
> @@ -2835,6 +2832,9 @@ static int netlink_show_sock(const struct socka=
ddr_nl *addr,
>  		printf("\n");
>  	}
> =20
> +	if (json_output)
> +		jsonw_end_object(json_wr);
> +
>  	return 0;
>  }
> =20
> @@ -3042,32 +3042,7 @@ static int print_summary(void)
> =20
>  	get_slabstat(&slabstat);
> =20
> -	printf("Total: %d (kernel %d)\n", s.socks, slabstat.socks);
> -
> -	printf("TCP:   %d (estab %d, closed %d, orphaned %d, synrecv %d, ti=
mewait %d/%d), ports %d\n",
> -	       s.tcp_total + slabstat.tcp_syns + s.tcp_tws,
> -	       sn.tcp_estab,
> -	       s.tcp_total - (s.tcp4_hashed+s.tcp6_hashed-s.tcp_tws),
> -	       s.tcp_orphans,
> -	       slabstat.tcp_syns,
> -	       s.tcp_tws, slabstat.tcp_tws,
> -	       slabstat.tcp_ports
> -	       );
> -
> -	printf("\n");
> -	printf("Transport Total     IP        IPv6\n");
> -	printf("*	  %-9d %-9s %-9s\n", slabstat.socks, "-", "-");
> -	printf("RAW	  %-9d %-9d %-9d\n", s.raw4+s.raw6, s.raw4, s.raw6);
> -	printf("UDP	  %-9d %-9d %-9d\n", s.udp4+s.udp6, s.udp4, s.udp6);
> -	printf("TCP	  %-9d %-9d %-9d\n", s.tcp4_hashed+s.tcp6_hashed, s.tcp=
4_hashed, s.tcp6_hashed);
> -	printf("INET	  %-9d %-9d %-9d\n",
> -	       s.raw4+s.udp4+s.tcp4_hashed+
> -	       s.raw6+s.udp6+s.tcp6_hashed,
> -	       s.raw4+s.udp4+s.tcp4_hashed,
> -	       s.raw6+s.udp6+s.tcp6_hashed);
> -	printf("FRAG	  %-9d %-9d %-9d\n", s.frag4+s.frag6, s.frag4, s.frag6=
);
> -
> -	printf("\n");
> +	sock_summary_fmt(&s, &sn, &slabstat);
> =20
>  	return 0;
>  }
> @@ -3095,6 +3070,7 @@ static void _usage(FILE *dest)
>  "   -z, --contexts      display process and socket SELinux security =
contexts\n"
>  "   -N, --net           switch to the specified network namespace na=
me\n"
>  "\n"
> +"   -j, --json          format output in JSON\n"
>  "   -4, --ipv4          display only IP version 4 sockets\n"
>  "   -6, --ipv6          display only IP version 6 sockets\n"
>  "   -0, --packet        display PACKET sockets\n"
> @@ -3194,6 +3170,7 @@ static const struct option long_opts[] =3D {
>  	{ "help", 0, 0, 'h' },
>  	{ "context", 0, 0, 'Z' },
>  	{ "contexts", 0, 0, 'z' },
> +	{ "json", 0, 0, 'j' },
>  	{ "net", 1, 0, 'N' },
>  	{ 0 }
> =20
> @@ -3209,7 +3186,7 @@ int main(int argc, char *argv[])
>  	int ch;
>  	int state_filter =3D 0;
> =20
> -	while ((ch =3D getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:=
=46:vVzZN:",
> +	while ((ch =3D getopt_long(argc, argv, "dhaletuwxnro460spbEf:miA:D:=
=46:vVzZN:j",
>  				 long_opts, NULL)) !=3D EOF) {
>  		switch(ch) {
>  		case 'n':
> @@ -3390,6 +3367,12 @@ int main(int argc, char *argv[])
>  			if (netns_switch(optarg))
>  				exit(1);
>  			break;
> +		case 'j':
> +			json_wr =3D jsonw_new(stdout);
> +			jsonw_pretty(json_wr, true);
> +			fmt_type =3D FMT_JSON;
> +			json_output =3D 1;
> +			break;

Careful here: Users may very well call 'ss -j -j'. Unless it's
impossible for this code to leak or get screwed up by invoking it
multiple times, rather just set 'json_output =3D 1' or maybe better jus=
t
'fmt_type =3D FMT_JSON' and have a switch(fmt_type) afterwards which do=
es
the necessary init (hint: init callback ;).

>  		case 'h':
>  		case '?':
>  			help();
> @@ -3401,12 +3384,6 @@ int main(int argc, char *argv[])
>  	argc -=3D optind;
>  	argv +=3D optind;
> =20
> -	if (do_summary) {
> -		print_summary();
> -		if (do_default && argc =3D=3D 0)
> -			exit(0);
> -	}
> -
>  	/* Now parse filter... */
>  	if (argc =3D=3D 0 && filter_fp) {
>  		if (ssfilter_parse(&current_filter.f, 0, NULL, filter_fp))
> @@ -3471,11 +3448,24 @@ int main(int argc, char *argv[])
>  				exit(-1);
>  			}
>  		}
> +		jsonw_name(json_wr, "TCP");
> +		jsonw_start_array(json_wr);
>  		inet_show_netlink(&current_filter, dump_fp, IPPROTO_TCP);
> +		jsonw_end_array(json_wr);
> +		jsonw_destroy(&json_wr);
>  		fflush(dump_fp);
>  		exit(0);
>  	}
> =20
> +	if (do_summary) {
> +		print_summary();
> +		if (do_default && argc =3D=3D 0) {
> +			if (json_output)
> +				jsonw_destroy(&json_wr);
> +			exit(0);
> +		}
> +	}

Uhm, why move that do_summary conditional down here? Can't this lead
to extra output before the summary?

>  	if (ssfilter_parse(&current_filter.f, argc, argv, filter_fp))
>  		usage();
> =20
> @@ -3497,62 +3487,117 @@ int main(int argc, char *argv[])
>  		}
>  	}
> =20
> -	addrp_width =3D screen_width;
> -	addrp_width -=3D netid_width+1;
> -	addrp_width -=3D state_width+1;
> -	addrp_width -=3D 14;
> +	if (!json_output) {

Perfect case for init callbacks.

> -	if (addrp_width&1) {
> -		if (netid_width)
> -			netid_width++;
> -		else if (state_width)
> -			state_width++;
> -	}
> +		addrp_width =3D screen_width;
> +		addrp_width -=3D netid_width + 1;
> +		addrp_width -=3D state_width + 1;
> +		addrp_width -=3D 14;
> =20
> -	addrp_width /=3D 2;
> -	addrp_width--;
> +		if (addrp_width & 1) {
> +			if (netid_width)
> +				netid_width++;
> +			else if (state_width)
> +				state_width++;
> +		}
> =20
> -	serv_width =3D resolve_services ? 7 : 5;
> +		addrp_width /=3D 2;
> +		addrp_width--;
> =20
> -	if (addrp_width < 15+serv_width+1)
> -		addrp_width =3D 15+serv_width+1;
> +		serv_width =3D resolve_services ? 7 : 5;
> =20
> -	addr_width =3D addrp_width - serv_width - 1;
> +		if (addrp_width < 15 + serv_width + 1)
> +			addrp_width =3D 15 + serv_width + 1;
> =20
> -	if (netid_width)
> -		printf("%-*s ", netid_width, "Netid");
> -	if (state_width)
> -		printf("%-*s ", state_width, "State");
> -	printf("%-6s %-6s ", "Recv-Q", "Send-Q");
> +		addr_width =3D addrp_width - serv_width - 1;
> +		if (netid_width)
> +			printf("%-*s ", netid_width, "Netid");
> +		if (state_width)
> +			printf("%-*s ", state_width, "State");
> +		printf("%-6s %-6s ", "Recv-Q", "Send-Q");
> =20
> -	/* Make enough space for the local/remote port field */
> -	addr_width -=3D 13;
> -	serv_width +=3D 13;
> +		/* Make enough space for the local/remote port field */
> +		addr_width -=3D 13;
> +		serv_width +=3D 13;
> =20
> -	printf("%*s:%-*s %*s:%-*s\n",
> -	       addr_width, "Local Address", serv_width, "Port",
> -	       addr_width, "Peer Address", serv_width, "Port");
> +		printf("%*s:%-*s %*s:%-*s\n",
> +				addr_width, "Local Address", serv_width, "Port",
> +				addr_width, "Peer Address", serv_width, "Port");
> +	}
> +
> +	fflush(stdout);
> +
> +	if (current_filter.dbs & (1<<NETLINK_DB)) {
> +		if (json_output) {
> +			jsonw_name(json_wr, "NETLINK");
> +			jsonw_start_array(json_wr);
> +			netlink_show(&current_filter);

Missing call to jsonw_end_array() here?

> +		} else
> +			netlink_show(&current_filter);
> +	}
> +	if (current_filter.dbs & PACKET_DBM) {
> +		if (json_output) {
> +			jsonw_name(json_wr, "PACKET");
> +			jsonw_start_array(json_wr);
> +			packet_show(&current_filter);
> +			jsonw_end_array(json_wr);
> +		} else
> +			packet_show(&current_filter);
> +	}
> +	if (current_filter.dbs & UNIX_DBM) {
> +		if (json_output) {
> +			jsonw_name(json_wr, "UNIX");
> +			jsonw_start_array(json_wr);
> +			unix_show(&current_filter);
> +			jsonw_end_array(json_wr);
> +		} else
> +			unix_show(&current_filter);
> +	}
> +	if (current_filter.dbs & (1<<RAW_DB)) {
> +		if (json_output) {
> +			jsonw_name(json_wr, "RAW");
> +			jsonw_start_array(json_wr);
> +			raw_show(&current_filter);
> +			jsonw_end_array(json_wr);
> +		} else
> +			raw_show(&current_filter);
> +	}
> +	if (current_filter.dbs & (1<<UDP_DB)) {
> +		if (json_output) {
> +			jsonw_name(json_wr, "UDP");
> +			jsonw_start_array(json_wr);
> +			udp_show(&current_filter);
> +			jsonw_end_array(json_wr);
> +		} else
> +			udp_show(&current_filter);
> +	}
> +	if (current_filter.dbs & (1<<TCP_DB)) {
> +		if (json_output) {
> +			jsonw_name(json_wr, "TCP");
> +			jsonw_start_array(json_wr);
> +			tcp_show(&current_filter, IPPROTO_TCP);
> +			jsonw_end_array(json_wr);
> +		} else
> +			tcp_show(&current_filter, IPPROTO_TCP);
> +	}
> +	if (current_filter.dbs & (1<<DCCP_DB)) {
> +		if (json_output) {
> +			jsonw_name(json_wr, "DCCP");
> +			jsonw_start_array(json_wr);
> +			tcp_show(&current_filter, IPPROTO_DCCP);
> +			jsonw_end_array(json_wr);
> +		} else
> +			tcp_show(&current_filter, IPPROTO_DCCP);
> +	}

=46rankly, this whole construct is ugly. The question about whether
filters should affect json output at all aside, this should be cleaned
up. In the very basic form, move the json_output conditional into
jsonw_name(), jsonw_start_array() and jsonw_end_array(). You could also
move the json function calls into the *_show() functions.

> +
> +	if (json_output)
> +		jsonw_destroy(&json_wr);
> =20
>  	fflush(stdout);
> =20
>  	if (follow_events)
>  		exit(handle_follow_request(&current_filter));
> =20
> -	if (current_filter.dbs & (1<<NETLINK_DB))
> -		netlink_show(&current_filter);
> -	if (current_filter.dbs & PACKET_DBM)
> -		packet_show(&current_filter);
> -	if (current_filter.dbs & UNIX_DBM)
> -		unix_show(&current_filter);
> -	if (current_filter.dbs & (1<<RAW_DB))
> -		raw_show(&current_filter);
> -	if (current_filter.dbs & (1<<UDP_DB))
> -		udp_show(&current_filter);
> -	if (current_filter.dbs & (1<<TCP_DB))
> -		tcp_show(&current_filter, IPPROTO_TCP);
> -	if (current_filter.dbs & (1<<DCCP_DB))
> -		tcp_show(&current_filter, IPPROTO_DCCP);
> -
>  	if (show_users || show_proc_ctx || show_sock_ctx)
>  		user_ent_destroy();
> =20
> --=20
> 1.9.1
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

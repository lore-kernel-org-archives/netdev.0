From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH v7 06/10] ss: renaming and export of current_filter
Date: Tue, 27 Oct 2015 14:10:41 +0100
Message-ID: <20151027131041.GE26876@orbit.nwl.cc>
References: <1441913708-15532-1-git-send-email-matthias.tafelmeier@gmx.net>
 <1441913708-15532-7-git-send-email-matthias.tafelmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hagen@jauu.net, shemminger@osdl.org,
	fw@strlen.de, edumazet@google.com, daniel@iogearbox.net
To: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:46063 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751338AbbJ0NKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Oct 2015 09:10:43 -0400
Content-Disposition: inline
In-Reply-To: <1441913708-15532-7-git-send-email-matthias.tafelmeier@gmx.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 10, 2015 at 09:35:04PM +0200, Matthias Tafelmeier wrote:
> Exported current_filter as ss_current_filter, because in
> the fmt handlers, I need that piece of info to resolve out issues of json.

This patch should come before the patches using the new name.

> Signed-off-by: Matthias Tafelmeier <matthias.tafelmeier@gmx.net>
> ---
>  misc/ss.c | 154 +++++++++++++++++++++++++++++++-------------------------------
>  1 file changed, 78 insertions(+), 76 deletions(-)
> 
> diff --git a/misc/ss.c b/misc/ss.c
> index 7a1b6eb..6ff40a3 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -106,6 +106,7 @@ int show_sock_ctx = 0;
>  int user_ent_hash_build_init = 0;
>  int follow_events = 0;
>  int json_output = 0;
> +int json_first_elem = 1;

This seems to be unrelated?

>  
>  int netid_width;
>  int state_width;
> @@ -200,7 +201,7 @@ static const struct filter default_afs[AF_MAX] = {
>  };
>  
>  static int do_default = 1;
> -static struct filter current_filter;
> +struct filter ss_current_filter;
>  
>  static void filter_db_set(struct filter *f, int db)
>  {
> @@ -1182,7 +1183,7 @@ void *parse_hostcond(char *addr, bool is_port)
>  	struct aafilter a = { .port = -1 };
>  	struct aafilter *res;
>  	int fam = preferred_family;
> -	struct filter *f = &current_filter;
> +	struct filter *f = &ss_current_filter;

Is it necessary to rename the function? The scope of ss is not too big,
so I don't think clarification is necessary. At least this would shrink
down this patch to almost nothing. :)

>  
>  	if (fam == AF_UNIX || strncmp(addr, "unix:", 5) == 0) {
>  		char *p;
> @@ -1281,9 +1282,9 @@ void *parse_hostcond(char *addr, bool is_port)
>  			if (get_integer(&a.port, port, 0)) {
>  				struct servent *se1 = NULL;
>  				struct servent *se2 = NULL;
> -				if (current_filter.dbs&(1<<UDP_DB))
> +				if (ss_current_filter.dbs & (1 << UDP_DB))
>  					se1 = getservbyname(port, UDP_PROTO);
> -				if (current_filter.dbs&(1<<TCP_DB))
> +				if (ss_current_filter.dbs & (1 << TCP_DB))
>  					se2 = getservbyname(port, TCP_PROTO);
>  				if (se1 && se2 && se1->s_port != se2->s_port) {
>  					fprintf(stderr, "Error: ambiguous port \"%s\".\n", port);
> @@ -1297,9 +1298,9 @@ void *parse_hostcond(char *addr, bool is_port)
>  					struct scache *s;
>  					for (s = rlist; s; s = s->next) {
>  						if ((s->proto == UDP_PROTO &&
> -						     (current_filter.dbs&(1<<UDP_DB))) ||
> +						     (ss_current_filter.dbs&(1<<UDP_DB))) ||
>  						    (s->proto == TCP_PROTO &&
> -						     (current_filter.dbs&(1<<TCP_DB)))) {
> +						     (ss_current_filter.dbs&(1<<TCP_DB)))) {
>  							if (s->name && strcmp(s->name, port) == 0) {
>  								if (a.port > 0 && a.port != s->port) {
>  									fprintf(stderr, "Error: ambiguous port \"%s\".\n", port);
> @@ -3220,19 +3221,19 @@ int main(int argc, char *argv[])
>  			follow_events = 1;
>  			break;
>  		case 'd':
> -			filter_db_set(&current_filter, DCCP_DB);
> +			filter_db_set(&ss_current_filter, DCCP_DB);
>  			break;
>  		case 't':
> -			filter_db_set(&current_filter, TCP_DB);
> +			filter_db_set(&ss_current_filter, TCP_DB);
>  			break;
>  		case 'u':
> -			filter_db_set(&current_filter, UDP_DB);
> +			filter_db_set(&ss_current_filter, UDP_DB);
>  			break;
>  		case 'w':
> -			filter_db_set(&current_filter, RAW_DB);
> +			filter_db_set(&ss_current_filter, RAW_DB);
>  			break;
>  		case 'x':
> -			filter_af_set(&current_filter, AF_UNIX);
> +			filter_af_set(&ss_current_filter, AF_UNIX);
>  			break;
>  		case 'a':
>  			state_filter = SS_ALL;
> @@ -3241,25 +3242,25 @@ int main(int argc, char *argv[])
>  			state_filter = (1 << SS_LISTEN) | (1 << SS_CLOSE);
>  			break;
>  		case '4':
> -			filter_af_set(&current_filter, AF_INET);
> +			filter_af_set(&ss_current_filter, AF_INET);
>  			break;
>  		case '6':
> -			filter_af_set(&current_filter, AF_INET6);
> +			filter_af_set(&ss_current_filter, AF_INET6);
>  			break;
>  		case '0':
> -			filter_af_set(&current_filter, AF_PACKET);
> +			filter_af_set(&ss_current_filter, AF_PACKET);
>  			break;
>  		case 'f':
>  			if (strcmp(optarg, "inet") == 0)
> -				filter_af_set(&current_filter, AF_INET);
> +				filter_af_set(&ss_current_filter, AF_INET);
>  			else if (strcmp(optarg, "inet6") == 0)
> -				filter_af_set(&current_filter, AF_INET6);
> +				filter_af_set(&ss_current_filter, AF_INET6);
>  			else if (strcmp(optarg, "link") == 0)
> -				filter_af_set(&current_filter, AF_PACKET);
> +				filter_af_set(&ss_current_filter, AF_PACKET);
>  			else if (strcmp(optarg, "unix") == 0)
> -				filter_af_set(&current_filter, AF_UNIX);
> +				filter_af_set(&ss_current_filter, AF_UNIX);
>  			else if (strcmp(optarg, "netlink") == 0)
> -				filter_af_set(&current_filter, AF_NETLINK);
> +				filter_af_set(&ss_current_filter, AF_NETLINK);
>  			else if (strcmp(optarg, "help") == 0)
>  				help();
>  			else {
> @@ -3272,9 +3273,9 @@ int main(int argc, char *argv[])
>  		{
>  			char *p, *p1;
>  			if (!saw_query) {
> -				current_filter.dbs = 0;
> +				ss_current_filter.dbs = 0;
>  				state_filter = state_filter ?
> -				               state_filter : SS_CONN;
> +							state_filter : SS_CONN;
>  				saw_query = 1;
>  				do_default = 0;
>  			}
> @@ -3283,44 +3284,44 @@ int main(int argc, char *argv[])
>  				if ((p1 = strchr(p, ',')) != NULL)
>  					*p1 = 0;
>  				if (strcmp(p, "all") == 0) {
> -					filter_default_dbs(&current_filter);
> +					filter_default_dbs(&ss_current_filter);
>  				} else if (strcmp(p, "inet") == 0) {
> -					filter_db_set(&current_filter, UDP_DB);
> -					filter_db_set(&current_filter, DCCP_DB);
> -					filter_db_set(&current_filter, TCP_DB);
> -					filter_db_set(&current_filter, RAW_DB);
> +					filter_db_set(&ss_current_filter, UDP_DB);
> +					filter_db_set(&ss_current_filter, DCCP_DB);
> +					filter_db_set(&ss_current_filter, TCP_DB);
> +					filter_db_set(&ss_current_filter, RAW_DB);
>  				} else if (strcmp(p, "udp") == 0) {
> -					filter_db_set(&current_filter, UDP_DB);
> +					filter_db_set(&ss_current_filter, UDP_DB);
>  				} else if (strcmp(p, "dccp") == 0) {
> -					filter_db_set(&current_filter, DCCP_DB);
> +					filter_db_set(&ss_current_filter, DCCP_DB);
>  				} else if (strcmp(p, "tcp") == 0) {
> -					filter_db_set(&current_filter, TCP_DB);
> +					filter_db_set(&ss_current_filter, TCP_DB);
>  				} else if (strcmp(p, "raw") == 0) {
> -					filter_db_set(&current_filter, RAW_DB);
> +					filter_db_set(&ss_current_filter, RAW_DB);
>  				} else if (strcmp(p, "unix") == 0) {
> -					filter_db_set(&current_filter, UNIX_ST_DB);
> -					filter_db_set(&current_filter, UNIX_DG_DB);
> -					filter_db_set(&current_filter, UNIX_SQ_DB);
> +					filter_db_set(&ss_current_filter, UNIX_ST_DB);
> +					filter_db_set(&ss_current_filter, UNIX_DG_DB);
> +					filter_db_set(&ss_current_filter, UNIX_SQ_DB);
>  				} else if (strcasecmp(p, "unix_stream") == 0 ||
>  					   strcmp(p, "u_str") == 0) {
> -					filter_db_set(&current_filter, UNIX_ST_DB);
> +					filter_db_set(&ss_current_filter, UNIX_ST_DB);
>  				} else if (strcasecmp(p, "unix_dgram") == 0 ||
>  					   strcmp(p, "u_dgr") == 0) {
> -					filter_db_set(&current_filter, UNIX_DG_DB);
> +					filter_db_set(&ss_current_filter, UNIX_DG_DB);
>  				} else if (strcasecmp(p, "unix_seqpacket") == 0 ||
>  					   strcmp(p, "u_seq") == 0) {
> -					filter_db_set(&current_filter, UNIX_SQ_DB);
> +					filter_db_set(&ss_current_filter, UNIX_SQ_DB);
>  				} else if (strcmp(p, "packet") == 0) {
> -					filter_db_set(&current_filter, PACKET_R_DB);
> -					filter_db_set(&current_filter, PACKET_DG_DB);
> +					filter_db_set(&ss_current_filter, PACKET_R_DB);
> +					filter_db_set(&ss_current_filter, PACKET_DG_DB);
>  				} else if (strcmp(p, "packet_raw") == 0 ||
>  					   strcmp(p, "p_raw") == 0) {
> -					filter_db_set(&current_filter, PACKET_R_DB);
> +					filter_db_set(&ss_current_filter, PACKET_R_DB);
>  				} else if (strcmp(p, "packet_dgram") == 0 ||
>  					   strcmp(p, "p_dgr") == 0) {
> -					filter_db_set(&current_filter, PACKET_DG_DB);
> +					filter_db_set(&ss_current_filter, PACKET_DG_DB);
>  				} else if (strcmp(p, "netlink") == 0) {
> -					filter_db_set(&current_filter, NETLINK_DB);
> +					filter_db_set(&ss_current_filter, NETLINK_DB);
>  				} else {
>  					fprintf(stderr, "ss: \"%s\" is illegal socket table id\n", p);
>  					usage();
> @@ -3386,7 +3387,7 @@ int main(int argc, char *argv[])
>  
>  	/* Now parse filter... */
>  	if (argc == 0 && filter_fp) {
> -		if (ssfilter_parse(&current_filter.f, 0, NULL, filter_fp))
> +		if (ssfilter_parse(&ss_current_filter.f, 0, NULL, filter_fp))
>  			usage();
>  	}
>  
> @@ -3412,32 +3413,32 @@ int main(int argc, char *argv[])
>  
>  	if (do_default) {
>  		state_filter = state_filter ? state_filter : SS_CONN;
> -		filter_default_dbs(&current_filter);
> +		filter_default_dbs(&ss_current_filter);
>  	}
>  
> -	filter_states_set(&current_filter, state_filter);
> -	filter_merge_defaults(&current_filter);
> +	filter_states_set(&ss_current_filter, state_filter);
> +	filter_merge_defaults(&ss_current_filter);
>  
>  	if (resolve_services && resolve_hosts &&
> -	    (current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB))))
> +	    (ss_current_filter.dbs&(UNIX_DBM|(1<<TCP_DB)|(1<<UDP_DB)|(1<<DCCP_DB))))
>  		init_service_resolver();
>  
> -	if (current_filter.dbs == 0) {
> +	if (ss_current_filter.dbs == 0) {
>  		fprintf(stderr, "ss: no socket tables to show with such filter.\n");
>  		exit(0);
>  	}
> -	if (current_filter.families == 0) {
> +	if (ss_current_filter.families == 0) {
>  		fprintf(stderr, "ss: no families to show with such filter.\n");
>  		exit(0);
>  	}
> -	if (current_filter.states == 0) {
> +	if (ss_current_filter.states == 0) {
>  		fprintf(stderr, "ss: no socket states to show with such filter.\n");
>  		exit(0);
>  	}
>  
>  	if (dump_tcpdiag) {
>  		FILE *dump_fp = stdout;
> -		if (!(current_filter.dbs & (1<<TCP_DB))) {
> +		if (!(ss_current_filter.dbs & (1<<TCP_DB))) {
>  			fprintf(stderr, "ss: tcpdiag dump requested and no tcp in filter.\n");
>  			exit(0);
>  		}
> @@ -3450,7 +3451,7 @@ int main(int argc, char *argv[])
>  		}
>  		jsonw_name(json_wr, "TCP");
>  		jsonw_start_array(json_wr);
> -		inet_show_netlink(&current_filter, dump_fp, IPPROTO_TCP);
> +		inet_show_netlink(&ss_current_filter, dump_fp, IPPROTO_TCP);
>  		jsonw_end_array(json_wr);
>  		jsonw_destroy(&json_wr);
>  		fflush(dump_fp);
> @@ -3466,15 +3467,15 @@ int main(int argc, char *argv[])
>  		}
>  	}
>  
> -	if (ssfilter_parse(&current_filter.f, argc, argv, filter_fp))
> +	if (ssfilter_parse(&ss_current_filter.f, argc, argv, filter_fp))
>  		usage();
>  
>  	netid_width = 0;
> -	if (current_filter.dbs&(current_filter.dbs-1))
> +	if (ss_current_filter.dbs & (ss_current_filter.dbs - 1))
>  		netid_width = 5;
>  
>  	state_width = 0;
> -	if (current_filter.states&(current_filter.states-1))
> +	if (ss_current_filter.states & (ss_current_filter.states - 1))
>  		state_width = 10;
>  
>  	screen_width = 80;
> @@ -3527,67 +3528,68 @@ int main(int argc, char *argv[])
>  
>  	fflush(stdout);
>  
> -	if (current_filter.dbs & (1<<NETLINK_DB)) {
> +	if (ss_current_filter.dbs & (1<<NETLINK_DB)) {
>  		if (json_output) {
>  			jsonw_name(json_wr, "NETLINK");
>  			jsonw_start_array(json_wr);
> -			netlink_show(&current_filter);
> +			netlink_show(&ss_current_filter);
> +			jsonw_end_array(json_wr);
>  		} else
> -			netlink_show(&current_filter);
> +			netlink_show(&ss_current_filter);
>  	}
> -	if (current_filter.dbs & PACKET_DBM) {
> +	if (ss_current_filter.dbs & PACKET_DBM) {
>  		if (json_output) {
>  			jsonw_name(json_wr, "PACKET");
>  			jsonw_start_array(json_wr);
> -			packet_show(&current_filter);
> +			packet_show(&ss_current_filter);
>  			jsonw_end_array(json_wr);
>  		} else
> -			packet_show(&current_filter);
> +			packet_show(&ss_current_filter);
>  	}
> -	if (current_filter.dbs & UNIX_DBM) {
> +	if (ss_current_filter.dbs & UNIX_DBM) {
>  		if (json_output) {
>  			jsonw_name(json_wr, "UNIX");
>  			jsonw_start_array(json_wr);
> -			unix_show(&current_filter);
> +			unix_show(&ss_current_filter);
>  			jsonw_end_array(json_wr);
>  		} else
> -			unix_show(&current_filter);
> +			unix_show(&ss_current_filter);
>  	}
> -	if (current_filter.dbs & (1<<RAW_DB)) {
> +	if (ss_current_filter.dbs & (1<<RAW_DB)) {
>  		if (json_output) {
>  			jsonw_name(json_wr, "RAW");
>  			jsonw_start_array(json_wr);
> -			raw_show(&current_filter);
> +			raw_show(&ss_current_filter);
>  			jsonw_end_array(json_wr);
>  		} else
> -			raw_show(&current_filter);
> +			raw_show(&ss_current_filter);
>  	}
> -	if (current_filter.dbs & (1<<UDP_DB)) {
> +	if (ss_current_filter.dbs & (1<<UDP_DB)) {
>  		if (json_output) {
>  			jsonw_name(json_wr, "UDP");
>  			jsonw_start_array(json_wr);
> -			udp_show(&current_filter);
> +			udp_show(&ss_current_filter);
>  			jsonw_end_array(json_wr);
>  		} else
> -			udp_show(&current_filter);
> +			udp_show(&ss_current_filter);
>  	}
> -	if (current_filter.dbs & (1<<TCP_DB)) {
> +	if (ss_current_filter.dbs & (1<<TCP_DB)) {
>  		if (json_output) {
>  			jsonw_name(json_wr, "TCP");
>  			jsonw_start_array(json_wr);
> -			tcp_show(&current_filter, IPPROTO_TCP);
> +			tcp_show(&ss_current_filter, IPPROTO_TCP);
>  			jsonw_end_array(json_wr);
>  		} else
> -			tcp_show(&current_filter, IPPROTO_TCP);
> +			tcp_show(&ss_current_filter, IPPROTO_TCP);
>  	}
> -	if (current_filter.dbs & (1<<DCCP_DB)) {
> +	if (ss_current_filter.dbs & (1<<DCCP_DB)) {
>  		if (json_output) {
>  			jsonw_name(json_wr, "DCCP");
>  			jsonw_start_array(json_wr);
> -			tcp_show(&current_filter, IPPROTO_DCCP);
> +			tcp_show(&ss_current_filter, IPPROTO_DCCP);
>  			jsonw_end_array(json_wr);
>  		} else
> -			tcp_show(&current_filter, IPPROTO_DCCP);
> +			tcp_show(&ss_current_filter, IPPROTO_DCCP);
>  	}
>  
>  	if (json_output)
> @@ -3596,7 +3598,7 @@ int main(int argc, char *argv[])
>  	fflush(stdout);
>  
>  	if (follow_events)
> -		exit(handle_follow_request(&current_filter));
> +		exit(handle_follow_request(&ss_current_filter));
>  
>  	if (show_users || show_proc_ctx || show_sock_ctx)
>  		user_ent_destroy();
> -- 
> 1.9.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

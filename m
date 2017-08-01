From: Roman Mashak <mrv@mojatatu.com>
Subject: Re: [PATCH RFC, iproute2] tc/mirred: Extend the mirred/redirect action to accept additional traffic class parameter
Date: Tue, 01 Aug 2017 10:02:24 -0400
Message-ID: <85tw1rbd3j.fsf@mojatatu.com>
References: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        alexander.h.duyck@intel.com, kiran.patil@intel.com,
        sridhar.samudrala@intel.com, mitch.a.williams@intel.com,
        alexander.duyck@gmail.com, neerav.parikh@intel.com,
        carolyn.wyborny@intel.com, jeffrey.t.kirsher@intel.com
To: Amritha Nambiar <amritha.nambiar@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36044 "EHLO
        mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751823AbdHAOCe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 10:02:34 -0400
Received: by mail-io0-f180.google.com with SMTP id g35so8585028ioi.3
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 07:02:34 -0700 (PDT)
In-Reply-To: <150154805003.4819.12498976860683140342.stgit@anamdev.jf.intel.com>
        (Amritha Nambiar's message of "Mon, 31 Jul 2017 17:40:50 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Amritha Nambiar <amritha.nambiar@intel.com> writes:

[...]

> @@ -72,6 +73,8 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
>  	struct tc_mirred p = {};
>  	struct rtattr *tail;
>  	char d[16] = {};
> +	__u32 flags = 0;
> +	__u8 tc;
>  
>  	while (argc > 0) {
>  
> @@ -142,6 +145,18 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
>  				argc--;
>  				argv++;
>  
> +				if ((argc > 0) && (matches(*argv, "tc") == 0)) {
> +					NEXT_ARG();
> +					tc = atoi(*argv);

Probably better to use strtol() instead, somebody wants to specify hex
base, also it has stronger error checks.

> +					if (tc >= MIRRED_TC_MAP_MAX) {
> +						fprintf(stderr, "Invalid TC index\n");
> +						return -1;
> +					}
> +					flags |= MIRRED_F_TC_MAP;
> +					ok++;
> +					argc--;
> +					argv++;
> +				}
>  				break;
>  
>  			}
> @@ -193,6 +208,9 @@ parse_direction(struct action_util *a, int *argc_p, char ***argv_p,
>  	tail = NLMSG_TAIL(n);
>  	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
>  	addattr_l(n, MAX_MSG, TCA_MIRRED_PARMS, &p, sizeof(p));
> +	if (flags & MIRRED_F_TC_MAP)
> +		addattr_l(n, MAX_MSG, TCA_MIRRED_TC_MAP,
> +			  &tc, sizeof(tc));
>  	tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
>  
>  	*argc_p = argc;
> @@ -248,6 +266,7 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
>  	struct tc_mirred *p;
>  	struct rtattr *tb[TCA_MIRRED_MAX + 1];
>  	const char *dev;
> +	__u8 *tc;
>  
>  	if (arg == NULL)
>  		return -1;
> @@ -273,6 +292,11 @@ print_mirred(struct action_util *au, FILE * f, struct rtattr *arg)
>  	fprintf(f, "mirred (%s to device %s)", mirred_n2a(p->eaction), dev);
>  	print_action_control(f, " ", p->action, "");
>  

> +	if (tb[TCA_MIRRED_TC_MAP]) {
> +		tc = RTA_DATA(tb[TCA_MIRRED_TC_MAP]);
> +		fprintf(f, " tc %d", *tc);

'tc' is declared as __u8 so format should be %u

> +	}
> +
>  	fprintf(f, "\n ");
>  	fprintf(f, "\tindex %u ref %d bind %d", p->index, p->refcnt,
>  		p->bindcnt);

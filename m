From: Paul Blakey <paulb@mellanox.com>
Subject: Re: [PATCH iproute2 v3 1/1] actions: Add support for user cookies
Date: Wed, 22 Mar 2017 14:06:37 +0200
Message-ID: <8b2fc8b7-64e2-c27d-a51c-25108cb5c41a@mellanox.com>
References: <1490133697-14469-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1255"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <paulb@mellanox.com>, <netdev@vger.kernel.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>, <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0073.outbound.protection.outlook.com ([104.47.1.73]:64856
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S934121AbdCVMGp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 22 Mar 2017 08:06:45 -0400
In-Reply-To: <1490133697-14469-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jamal,
I've tested the patch some and I've put some comments below:

On 22/03/2017 00:01, Jamal Hadi Salim wrote:
> From: Jamal Hadi Salim <jhs@mojatatu.com>
>
> Make use of 128b user cookies
>
> Introduce optional 128-bit action cookie.
> Like all other cookie schemes in the networking world (eg in protocols
> like http or existing kernel fib protocol field, etc) the idea is to
> save user state that when retrieved serves as a correlator. The kernel
> _should not_ intepret it. The user can store whatever they wish in the
> 128 bits.
>
> Sample exercise(showing variable length use of cookie)
>
> .. create an accept action with cookie a1b2c3d4
> sudo $TC actions add action ok index 1 cookie a1b2c3d4
>
> .. dump all gact actions..
> sudo $TC -s actions ls action gact
>
>     action order 0: gact action pass
>      random type none pass val 0
>      index 1 ref 1 bind 0 installed 5 sec used 5 sec
>     Action statistics:
>     Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
>     backlog 0b 0p requeues 0
>     cookie a1b2c3d4
>
> .. bind the accept action to a filter..
> sudo $TC filter add dev lo parent ffff: protocol ip prio 1 \
> u32 match ip dst 127.0.0.1/32 flowid 1:1 action gact index 1
>
> ... send some traffic..
> $ ping 127.0.0.1 -c 3
> PING 127.0.0.1 (127.0.0.1) 56(84) bytes of data.
> 64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.020 ms
> 64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.027 ms
> 64 bytes from 127.0.0.1: icmp_seq=3 ttl=64 time=0.038 ms
>
> Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
> ---
>  tc/m_action.c | 44 ++++++++++++++++++++++++++++++++++++++------
>  1 file changed, 38 insertions(+), 6 deletions(-)
>
> diff --git a/tc/m_action.c b/tc/m_action.c
> index 05ef07e..6ba7615 100644
> --- a/tc/m_action.c
> +++ b/tc/m_action.c
> @@ -150,18 +150,19 @@ new_cmd(char **argv)
>
>  }
>
> -int
> -parse_action(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
> +int parse_action(int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
>  {
>  	int argc = *argc_p;
>  	char **argv = *argv_p;
>  	struct rtattr *tail, *tail2;
>  	char k[16];
> +	int act_ck_len = 0;
>  	int ok = 0;
>  	int eap = 0; /* expect action parameters */
>
>  	int ret = 0;
>  	int prio = 0;
> +	unsigned char act_ck[TC_COOKIE_MAX_SIZE];
>
>  	if (argc <= 0)
>  		return -1;
> @@ -215,16 +216,39 @@ done0:
>  			addattr_l(n, MAX_MSG, ++prio, NULL, 0);
>  			addattr_l(n, MAX_MSG, TCA_ACT_KIND, k, strlen(k) + 1);
>
> -			ret = a->parse_aopt(a, &argc, &argv, TCA_ACT_OPTIONS, n);
> +			ret = a->parse_aopt(a, &argc, &argv, TCA_ACT_OPTIONS,
> +					    n);
>
>  			if (ret < 0) {
>  				fprintf(stderr, "bad action parsing\n");
>  				goto bad_val;
>  			}
> +
> +			if (*argv && strcmp(*argv, "cookie") == 0) {
> +				size_t slen;
> +
> +				NEXT_ARG();
> +				slen = strlen(*argv);
> +				if (slen > TC_COOKIE_MAX_SIZE * 2)
> +					invarg("cookie cannot exceed %d\n",
> +					       *argv);
> +

invarg doesn't take a format string, but two strings, name of arg that 
is wrong and why it is wrong.
Also you probably  meant to print TC_COOKIE_MAX_SIZE*2

> +				if (hex2mem(*argv, act_ck, slen / 2) < 0)
> +					invarg("cookie must be a hex string\n",
> +					       *argv);

same, *argv, should probably be "cookie" and msg should be "must be a 
hex string"

Also cookie of length 1 doesn't work here.

> +
> +				act_ck_len = slen;
> +				argc--;
> +				argv++;
> +			}
> +
> +			if (act_ck_len)
> +				addattr_l(n, MAX_MSG, TCA_ACT_COOKIE,
> +					  &act_ck, act_ck_len);
> +
>  			tail->rta_len = (void *) NLMSG_TAIL(n) - (void *) tail;
>  			ok++;
>  		}
> -
>  	}
>
>  	if (eap > 0) {
> @@ -245,8 +269,7 @@ bad_val:
>  	return -1;
>  }
>
> -static int
> -tc_print_one_action(FILE *f, struct rtattr *arg)
> +static int tc_print_one_action(FILE *f, struct rtattr *arg)
>  {
>
>  	struct rtattr *tb[TCA_ACT_MAX + 1];
> @@ -274,8 +297,17 @@ tc_print_one_action(FILE *f, struct rtattr *arg)
>  		return err;
>
>  	if (show_stats && tb[TCA_ACT_STATS]) {
> +
>  		fprintf(f, "\tAction statistics:\n");
>  		print_tcstats2_attr(f, tb[TCA_ACT_STATS], "\t", NULL);
> +		if (tb[TCA_ACT_COOKIE]) {
> +			int strsz = RTA_PAYLOAD(tb[TCA_ACT_COOKIE]);
> +			char b1[strsz+1];
> +
> +			fprintf(f, "\n\tcookie len %d %s ", strsz,
> +				hexstring_n2a(RTA_DATA(tb[TCA_ACT_COOKIE]),
> +					      strsz, b1, sizeof(b1)));

Dumping a cookie with odd length (which is acceptable) doesn't print it 
in its entirely since hexstring_n2a prints in pairs.
And in the case of lengh 1 its garbled since it didn't actually read it.

> +		}
>  		fprintf(f, "\n");
>  	}
>
>

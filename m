From: jamal <hadi@cyberus.ca>
Subject: Re: instead of eaction
Date: 07 Feb 2005 08:57:01 -0500
Message-ID: <1107784621.1053.66.camel@jzny.localdomain>
References: <1107728020.1055.50.camel@jzny.localdomain>
	 <20050206230859.GY31837@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-IRTkFurCO5W8ODvYvTMn"
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050206230859.GY31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-IRTkFurCO5W8ODvYvTMn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sun, 2005-02-06 at 18:08, Thomas Graf wrote:

> 
> > --- /dev/null	2004-01-29 13:33:32.773091056 -0500
> > +++ 2611-rc3+bk3/include/net/act_generic.h	2005-02-06 15:55:36.000000000 -0500
> > +	if (rta == NULL || rtattr_parse_nested(tb, TCA_DEF_MAX, rta) < 0)
> > +		return -EINVAL;
> > +
> > +	if (tb[TCA_DEF_PARMS - 1] == NULL)
> > +		return -EINVAL;
> 
> Maybe check for tb[TCA_DEF_DATA - 1] == NULL here as well?
> 

Good point; i will check for all

> > +	parm = RTA_DATA(tb[TCA_DEF_PARMS - 1]);
> 
> RTA_PAYLOAD check for TCA_DEF_PARMS?
> 

sure

> > --- /dev/null	2004-01-29 13:33:32.773091056 -0500
> > +++ 2611-rc3+bk3/net/sched/simple.c	2005-02-06 15:55:57.000000000 -0500
> > @@ -0,0 +1,107 @@
> 
> > +#include <linux/tc_act/tc_defact.h>
> > +#include <net/tc_act/tc_defact.h>
> > +
> > +/* use generic hash table with 8 buckets */
> > +#define MY_TAB_SIZE     8
> > +#define MY_TAB_MASK     (MY_TAB_SIZE - 1)
> > +static u32 idx_gen;
> > +static struct tcf_defact *tcf_simp_ht[MY_TAB_SIZE];
> > +static DEFINE_RWLOCK(simp_lock);
> 
> I guess this is supposed to be tca_use_default_defines
> and move MY_TAB_SIZE before the includes?

This is a tricky one; maybe i am playing too many macro tricks ;->
Theres some dependencies - need to think a little

> It looks pretty simple to use and makes up ematches quite well. Any
> userspace code alreay written?

User space could be simplified as well; attached is what i used to test
simple action. Theres a _lot_ of common code there as well.

I am also bgining to work on the checksum action; i will then do the
meta action. 

cheers,
jamal

--=-IRTkFurCO5W8ODvYvTMn
Content-Disposition: attachment; filename=m_simple.c
Content-Type: text/x-c; name=m_simple.c; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

/*
 * m_defact.c		simple example action module 
 *
 *		This program is free software; you can distribute it and/or
 *		modify it under the terms of the GNU General Public License
 *		as published by the Free Software Foundation; either version
 *		2 of the License, or (at your option) any later version.
 *
 * Authors:  J Hadi Salim (hadi@cyberus.ca) 
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <syslog.h>
#include <fcntl.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <string.h>

#include "utils.h"
#include "tc_util.h"
#include <linux/tc_act/tc_defact.h>

static void
explain(void)
{
	fprintf(stderr, "Usage: ... simp <ACT_STRING> index [INDEX]\n");
	fprintf(stderr,
		"Where: ACT_STRING := a simple string (not exceeding 16 chars"
		"INDEX := index value used\n");
}

#define usage() return(-1)

#ifndef ANAMSIZ
#define ANAMSIZ 16
#endif

int
parse_simple(struct action_util *a, int *argc_p, char ***argv_p, int tca_id, struct nlmsghdr *n)
{
	int argc = *argc_p;
	char **argv = *argv_p;
	struct tc_defact *p;
	char  k[ANAMSIZ];
	struct rtattr *tail;

	if (argc < 2)
		return -1;

	p = malloc(sizeof(*p));
	memset(p, 0, sizeof(*p));
	memset (&k,0,ANAMSIZ);

	NEXT_ARG();
	strncpy(k, *argv, sizeof(k)-1);
	argc--; argv++;
	if (argc && matches(*argv, "index") == 0) {
		NEXT_ARG();
		if (get_u32(&p->index, *argv, 10)) {
			fprintf(stderr, "Illegal \"index\"\n");
			return -1;
		}
		argc--;
		argv++;
	}
		

	p->action = TC_ACT_PIPE;

	tail = (struct rtattr *) (((void *) n) + NLMSG_ALIGN(n->nlmsg_len));
	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
	addattr_l(n, MAX_MSG, TCA_DEF_PARMS, p, sizeof(*p));
	addattr_l(n, MAX_MSG, TCA_DEF_DATA, k, strlen(k)+1);
	tail->rta_len =
	    (((void *) n) + NLMSG_ALIGN(n->nlmsg_len)) - (void *) tail;

	*argc_p = argc;
	*argv_p = argv;
	return 0;
}

int
print_simple(struct action_util *au,FILE * f, struct rtattr *arg)
{
	SPRINT_BUF(b1);
	struct tc_defact *p = NULL;
	struct rtattr *tb[TCA_DEF_MAX + 1];
	char *str;

	if (arg == NULL)
		return -1;

	memset(tb, 0, sizeof (tb));
	parse_rtattr(tb, TCA_DEF_MAX, RTA_DATA(arg), RTA_PAYLOAD(arg));

	if (tb[TCA_DEF_PARMS] == NULL) {
		fprintf(f, "[NULL simple parameters]");
		return -1;
	}
	p = RTA_DATA(tb[TCA_DEF_PARMS]);

	fprintf(f, "simple action %s", action_n2a(p->action, b1, sizeof (b1)));
	fprintf(f, "\n\t index %d ref %d bind %d",p->index, p->refcnt, p->bindcnt);
	if (show_stats) {
		if (tb[TCA_DEF_TM]) {
			struct tcf_t *tm = RTA_DATA(tb[TCA_DEF_TM]);
			print_tm(f,tm);
		}
	}
	str = RTA_DATA(tb[TCA_DEF_DATA]);

	if (!strlen(str)) {
		 fprintf(f, "\n\t EMPTY string!!!\n");
	} else {
		 fprintf(f, "\n\t DATA: <%s>\n",str);
	}

	fprintf(f, "\n ");
	return 0;
}

struct action_util simple_action_util = {
	.id = "simple",
	.parse_aopt = parse_simple,
	.print_aopt = print_simple,
};

--=-IRTkFurCO5W8ODvYvTMn--

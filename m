From: "David S. Miller" <davem@redhat.com>
Subject: Re: O/M flags against 2.6.0-test1
Date: Mon, 4 Aug 2003 16:57:46 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030804165746.133f370a.davem@redhat.com>
References: <20030730220223.4c25fcfe.davem@redhat.com>
	<Pine.LNX.4.44.0307311330200.27478-100000@DYN318430>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, netdev@oss.sgi.com,
   krkumar@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Krishna Kumar <krkumar@us.ibm.com>
In-Reply-To: <Pine.LNX.4.44.0307311330200.27478-100000@DYN318430>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 31 Jul 2003 13:33:27 -0700 (PDT)
Krishna Kumar <krkumar@us.ibm.com> wrote:

> > Ok, but then please use "__s32".
> 
> OK, slowly getting there :-)
> 
> Latest patch follows :

Krishna is away, but let us make more progress on this patch.
I see some problem with it that still need to be resolved:

> +/* Subtype attributes for IFLA_PROTINFO */
> +enum
> +{
> +	IFLA_INET6_UNSPEC,
> +	IFLA_INET6_FLAGS,	/* link flags			*/
> +	IFLA_INET6_CONF,	/* sysctl parameters		*/
> +	IFLA_INET6_STATS,	/* statistics			*/
> +	IFLA_INET6_MCAST,	/* MC things. What of them?	*/
> +};
> +
> +#define IFLA_INET6_MAX	IFLA_INET6_MCAST

Ok, how does this actually work?  The code does RTA_PUT(...IFLA_INET6_*...)
but IFLA_PROTINFO is not actually used anywhere.  This cannot work, it makes
these RTA attributes just look like whatever IFLA_* ones have the
same values as the inet6 ones in this enumeration.

Alexey, how did you intend this stuff to be done?  Cerainly not
like this :-)

> +	/* return the device sysctl params */
> +	if ((array = kmalloc(DEVCONF_MAX * sizeof(*array), GFP_KERNEL)) == NULL)
> +		goto rtattr_failure;
> +	ipv6_store_devconf(&idev->cnf, array);
> +	RTA_PUT(skb, IFLA_INET6_CONF, DEVCONF_MAX * sizeof(*array), array);

This is what I'm talking about.  Maybe there is something I'm missing.
How does APP know to interpret IFLA_INET6_CONF as "sub-attribute"
of IFLA_PROTINFO?

Also, missing "memset(array, 0, sizeof(*array));" else we leak
uninitialized kernel memory into user space.

Another bug, GFP_KERNEL memory allocation with dev_base_lock held.

Otherwise I am OK with the patch.

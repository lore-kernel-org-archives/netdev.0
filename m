From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter
Date: Thu, 27 Jan 2005 15:24:50 -0800
Message-ID: <20050127152450.6daba4fa.davem@davemloft.net>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	<p73zn0ccaee.fsf@verdi.suse.de>
	<1105117559.11753.34.camel@baythorne.infradead.org>
	<20050107100017.454ddadc@dxpl.pdx.osdl.net>
	<1105133241.3375.16.camel@localhost.localdomain>
	<20050118135735.4b77d38d.davem@davemloft.net>
	<1106433059.4486.11.camel@localhost.localdomain>
	<1106436153.20995.42.camel@tux.rsn.bth.se>
	<1106484019.3376.5.camel@localhost.localdomain>
	<1106496509.1085.1.camel@tux.rsn.bth.se>
	<20050125220558.6e824f8a.davem@davemloft.net>
	<1106730510.4041.4.camel@localhost.localdomain>
	<41F82C6D.7020006@trash.net>
	<20050126231801.7bf90338.davem@davemloft.net>
	<41F929FA.3050800@trash.net>
	<20050127114726.2205b4ed.davem@davemloft.net>
	<41F96FA4.4000105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, snort2004@mail.ru,
        rusty@rustcorp.com.au, ak@suse.de, bridge@osdl.org,
        gandalf@wlug.westbo.se, dwmw2@infradead.org, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41F96FA4.4000105@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 23:48:04 +0100
Patrick McHardy <kaber@trash.net> wrote:

> David S. Miller wrote:
> 
> >In the generated asm on sparc64, invoke2() gets a tail-call
> >whereas invoke() does not.  Hmmm...
>
> Apparently support for indirect tail-calls was added to gcc 3.4.

Good data point.

I've been trying to figure out ways to decrease the number of
args that get sent to nf_hook_slow but this would require
some API changes unfortunately.

One idea goes like this, we create little descriptors of the form:

struct nf_hook_desc {
	int (*okfn)(struct sk_buff *);
	int pf;
	int hook;
};

Then NF_HOOK*() callsites do something like this:

static const struct nf_hook_desc nf_ip_local_out = {
	.okfn = dst_output,
	.pf = PF_INET,
	.hook = NF_IP_LOCAL_OUT,
};

...

	/* Send it out. */
	return NF_HOOK(&nf_ip_local_out, skb, NULL, rt->u.dst.dev);

This gets us down to 4 arguments from 6.  I think we can kill
one more.

It is never the case that both indev and outdev are both
set, so we can use some nf_hook_desc piece of state to
indicate which (in or out) the passed device pointer is.

Oh yes, we can nicely add the thresh thing in here too
while we're at it.

So the final nf_hook_desc might look something something like:

struct nf_hook_desc {
	int (*okfn)(struct sk_buff *);
	int hook;
	int thresh;
	u8 pf; /* AF_MAX is 32 */
	u8 is_output;
};

Hook could possibly use a smaller type as well to condense
the size of this thing even further.  I don't know if there
are any nice assumptions we can make about the hook numbers.

Now, back to the compatability issue.  We could create a
new macro, NF_HOOK_DESC() and keep the existing ones around
via some nf_hook_slow() that basically does:

int nf_hook_slow(int pf, unsigned int hook, struct sk_buff *skb,
		 struct net_device *indev, struct net_device *outdev,
		 int (*okfn)(struct sk_buff *), int thresh)
{
	struct nf_hook_desc desc;

	desc.okfn = okfn;
	desc.hook = hook;
	desc.thresh = thresh;
	desc.pf = pf;
	desc.is_output = (outdev != NULL);
	return nf_hook_desc(&desc, skb, (outdev ? outdev : indev));
}

So the final new stuff looks something like:

#ifdef CONFIG_NETFILTER
struct nf_hook_desc {
	int (*okfn)(struct sk_buff *);
	int hook;
	int thresh;
	u8 pf; /* AF_MAX is 32 */
	u8 is_output;
};
#define NF_DESC_DECLARE(_name, _okfn, _hook, _thresh, _pf, _is_output) \
static const struct nf_hook_desc _name = { \
	.okfn = _okfn, \
	.hook = _hook, \
	.thresh = _thresh, \
	.pf = _pf, \
	.is_output = _is_output, \
};

extern int nf_hook_desc(struct nf_hook_desc *desc, struct sk_buff *skb,
			struct net_device *dev);

#define NF_HOOK_DESC(_desc, _skb, _dev) \
	nf_hook_desc(_desc, _skb, _dev)
#endif

Just throwing around ideas... comments?

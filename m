From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH/RFC] Reduce call chain length in netfilter
Date: Wed, 26 Jan 2005 23:18:01 -0800
Message-ID: <20050126231801.7bf90338.davem@davemloft.net>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bdschuym@pandora.be, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org, snort2004@mail.ru,
        rusty@rustcorp.com.au, ak@suse.de, bridge@osdl.org,
        gandalf@wlug.westbo.se, dwmw2@infradead.org, shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <41F82C6D.7020006@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 27 Jan 2005 00:49:01 +0100
Patrick McHardy <kaber@trash.net> wrote:

> Bart De Schuymer wrote:
> 
> >Does anyone have objections to this patch, which reduces the netfilter
> >call chain length?
> >
> Looks fine to me.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Ok, I applied this.

While reviewing I thought it may be an issue that the new macros
potentially change skb.  It really isn't an issue because NF_HOOK()
calls pass ownership of the SKB over from the caller.

Although technically, someone could go:

	skb_get(skb);
	err = NF_HOOK(... skb ...);
	... do stuff with skb ...
	kfree_skb(skb);

but that would cause other problems and I audited the entire tree
and nobody attempts anything like this currently.  'skb' always
dies at the NF_HOOK() call site.

I guess if we wanted to preserve NF_HOOK*() semantics even in such
a case we could use a local "__skb" var in the macro's basic block.

Another huge downside to this change I was worried about
was from a code generation point of view.  Since we now take the
address of "skb", gcc cannot generate tail-calls for the common
case of:

	return NF_HOOK(...);

when netfilter is enabled.  Ho hum...

Wait...

This is actually an important point!  Since gcc is generating a tail-
call for NF_HOOK() today, there is no stack savings for NF_HOOK()
created by this patch.  The only real gain is the NF_STOP stuff
for bridge netfilter.

I'm backing this out of my tree, let's think about this some more.
Perhaps it's only worth adding the NF_STOP thing and just making
nf_hook_slow() do the okfn(skb); call in that case?

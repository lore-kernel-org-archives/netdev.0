From: jamal <hadi@cyberus.ca>
Subject: Re: [PKT_SCHED]: Allow using nfmark as key in U32 classifier.
Date: 03 Jan 2005 09:36:52 -0500
Message-ID: <1104763012.1047.524.camel@jzny.localdomain>
References: <20041230174313.GB32419@postel.suug.ch>
	 <1104469111.1049.219.camel@jzny.localdomain>
	 <20041231110836.GD32419@postel.suug.ch>
	 <1104505142.1048.262.camel@jzny.localdomain>
	 <20041231153930.GN32419@postel.suug.ch>
	 <1104511494.1048.303.camel@jzny.localdomain>
	 <20041231181153.GP32419@postel.suug.ch>
	 <1104526311.1047.379.camel@jzny.localdomain>
	 <20050101121041.GR32419@postel.suug.ch>
	 <1104622164.1048.444.camel@jzny.localdomain>
	 <20050102000612.GU32419@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050102000612.GU32419@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-01-01 at 19:06, Thomas Graf wrote:
> * jamal <1104622164.1048.444.camel@jzny.localdomain> 2005-01-01 18:29
> > Does the ematch API include a dump()? I dont think it should - thats the
> > point i was making. Should be simple.
> 
> Yes, although simple ematches are not required to implement dump.

ok. I realize its optional - but i wouldnt even give the writter of
ematch the opportunity to write one. Want something more complex? write
a classifier.

> > > [validate]
> > Even this is too much for a simple ematch. Validation should happen in
> > user space or maybe at the mother clasifier. maybe a maxsize,minsize
> > attribute is needed in the ematch struct.
> > > [replace]
> > Equivalent of this should be done by the mother classifier.
> > All it needs to know is the length (and no other details). And the
> > length is known from the L in TLV.
> 
> I merged validate/replace into change which takes a unsigned long
> for storage and a data/len parameter. It's up to the ematch what he
> does with it, data may contain a u32 directly and the ematch might
> save it in the unsigned long or a ematch may allocate a structure.

Again allowing for this may be overkill. Just send the same structure
the ematch needs in exactly the same form it needs it and you dont need
this. 

> Why are you focused on hiding so much? I'd rather try to make it
> simple but still allow more complex ematches to exist.
> 
> Have a look at http://people.suug.ch/~tgr/tmp/ematch.diff

Thanks, give me a few hours then i will look.

> I broke the API down to:
> 
> change
> match
> destroy (optional, only for complex ematches)
> dump (optional, only for complex ematches)
> 

Other than match, anything really should be optional for simplicity
sake.

> > Note that the ematch is supposed to be a very very simple thing...
> > Something a fireman who has implemented a iptables target can whip in an
> > hour. Keep in mind that design goal. Non trivial coding needed or poor
> > usability is the major problem with tc in general. Avoid that theme.
> > An ematch _needs_  a mother classifier such as u32. u32 has a very nice
> > and very flexible layout - it can be trained to build any sort of tree.
> > Maybe the first step should be to not even have u32 as an ematch ..
> 
> I understand your point but I want to at least be able to implement
> some more complex stuff. Hiding too much can be bad too. Having only 2
> functions to implement is really easy, the rest can be done the LinuxWay(tm) ;->
> 

True - but the goals of this ematch is to be simple ;->

> Have a look at the code and tell me what you think.
> 
> Here's an example ematch, I find this quite simple already.
> 
> static in foo_change(struct tcf_proto *tp, void *data, int len, struct
> 			tcf_ematch *m)
> {
> 	if (len != sizeof(u32))
> 		return -EINVAL;
> 	m->data = *(u32*)data;
> 	return 0;
> }
> 

I still say not needed ;->

> static int foo_match(struct sk_buff *skb, struct tcf_ematch *m)
> {
> 	return skb->security == m->data;
> }

makes sense.

> static struct tcf_ematch_ops foo_ops = {
> 	.kind	= 111,
> 	.change = foo_change,
> 	.match  = foo_match,
> 	.owner  = THIS_MODULE,
> 	.link	= LIST_HEAD_INIT(foo_ops.link)
> }

whats the .link for?

> static int __init foo_init(void)
> {
> 	return tcf_ematch_register(&foo_ops);
> }
> 
> static void __exit foo_exit(void)
> {
> 	return tcf_ematch_unregister(&foo_ops);
> }
> 
> module_init(init_foo);
> module_exit(exit_foo);

All looks good.  Give me a few hours, first day of working week will
slow me down.

cheers,
jamal

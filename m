From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: do_IRQ: stack overflow: 872..
Date: Fri, 7 Jan 2005 10:00:17 -0800
Message-ID: <20050107100017.454ddadc@dxpl.pdx.osdl.net>
References: <1131604877.20041218092730@mail.ru.suse.lists.linux.kernel>
	<p73zn0ccaee.fsf@verdi.suse.de>
	<1105117559.11753.34.camel@baythorne.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============66447518882067547=="
Cc: Crazy AMD K7 <snort2004@mail.ru>, bridge@osdl.org, Andi Kleen <ak@suse.de>,
   netdev@oss.sgi.com
Return-path: <bridge-bounces@lists.osdl.org>
To: David Woodhouse <dwmw2@infradead.org>,
   Bart De Schuymer
	<bdschuym@pandora.be>
In-Reply-To: <1105117559.11753.34.camel@baythorne.infradead.org>
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/bridge>
List-Post: <mailto:bridge@lists.osdl.org>
List-Help: <mailto:bridge-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.osdl.org?subject=subscribe>
Sender: bridge-bounces@lists.osdl.org
Errors-To: bridge-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============66447518882067547==
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 07 Jan 2005 17:05:59 +0000
David Woodhouse <dwmw2@infradead.org> wrote:

> On Sat, 2004-12-18 at 08:50 +0100, Andi Kleen wrote:
> > It's not really an oops, just a warning that stack space got quiet
> > tight.
> > 
> > The problem seems to be that the br netfilter code is nesting far too
> > deeply and recursing several times. Looks like a design bug to me,
> > it shouldn't do that.
> 
> I don't think it's recursing -- I think the stack trace is just a bit
> noisy. The problem is that the bridge code, especially with br_netfilter
> in the equation, is implicated in code paths which are just _too_ deep.
> This happens when you're bridging packets received in an interrupt while
> you were deep in journalling code, and it's also been seen with a call
> trace something like nfs->sunrpc->ip->bridge->br_netfilter.

Sounds like an argument for interrupt stacks.

> One option might be to make br_dev_xmit() just queue the packet rather
> than trying to deliver it to all the slave devices immediately. Then the
> actual retransmission can be handled from a context where we're _not_
> short of stack; perhaps from a dedicated kernel thread. 

Probably the solution would be to handle it in the filter code
that way if we are not filtering, we can use the interrupt path,
but if filtering just defer to a safer context (like soft irq).

> Unfortunately that approach would introduce a lot of latency on all
> packets we pass. Another option would be to have all architectures
> provide a stack_available() function and for br_dev_xmit() to queue the
> packet only if we're short of stack, while still sending most packets
> immediately. 

NO, that looks like a testablity and portablity nightmare.

--===============66447518882067547==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Bridge mailing list
Bridge@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/bridge

--===============66447518882067547==--

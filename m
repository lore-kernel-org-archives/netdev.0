From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch 13/26] Xen-paravirt_ops: Consistently wrap paravirt ops
	callsites to make them patchable
Date: Mon, 19 Mar 2007 11:44:42 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0703191138430.6730@woody.linux-foundation.org>
References: <20070316.023331.59468179.davem@davemloft.net>
	<45FB005D.9060809@goop.org>
	<1174127638.8897.75.camel@localhost.localdomain>
	<20070318.003309.71088169.davem@davemloft.net>
	<20070318120814.GA45869@muc.de>
	<1174272469.11680.23.camel@localhost.localdomain>
	<m1648xxf93.fsf@ebiederm.dsl.xmission.com>
	<Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: xen-devel@lists.xensource.com, virtualization@lists.osdl.org,
   netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
   David Miller <davem@davemloft.net>, chrisw@sous-sol.org,
   Andi Kleen <ak@muc.de>, anthony@codemonkey.ws, mingo@elte.hu,
   akpm@linux-foundation.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703191134190.6730@woody.linux-foundation.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/virtualization>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org



On Mon, 19 Mar 2007, Linus Torvalds wrote:
> =

> So *please* don't believe that you can make it "as cheap" to have some =

> automatic fixup of two sequences, one inlined and one as a "call".  It ma=
y =

> look so when you look at the single instruction generated, but you're =

> ignoring all the instructions *around* the site.

Side note, you can certainly fix things like this at least in theory, but =

it requires:

 - the "call" instruction that is used instead of the inlining should =

   basically have no callee-clobbers. Any paravirt_ops called this way
   should have a special calling sequence where they simple save and =

   restore all the registers they use.

   This is usually not that bad. Just create a per-architecture wrapper =

   function that saves/restores anything that the C calling convention on =

   that architecture says is clobbered by calls.

 - if the function has arguments, and the inlined sequence can take the =

   arguments in arbitrary registers, you are going to penalize the inlined =

   sequence anyway (by forcing some fixed arbitrary register allocation =

   policy).This thing is largely unfixable without some really extreme =

   compiler games (like post-processing the assembler output and having =

   different entry-points depending on where the arguments are..)

.. it will obviously depend on how thngs are done whether these things are =

useful or not. But it does mean that it's always a good idea to just have =

a config option of "turn off all the paravirt crap, because it *does* add =

overhead, and replacing instructions on the fly doesn't make that =

overhead go away".

		Linus

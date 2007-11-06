From: Radu Rendec <radu.rendec@ines.ro>
Subject: Re: Endianness problem with u32 classifier hash masks
Date: Tue, 06 Nov 2007 10:09:02 +0200
Message-ID: <1194336542.3305.33.camel@rad.rendec.ines.ro>
References: <1193939701.2987.82.camel@localhost.localdomain>
	 <472B5EF1.4020206@o2.pl> <1194045830.4438.21.camel@localhost>
	 <472D06B2.9040402@o2.pl> <472D0B1C.7000209@o2.pl> <472D128B.8030704@o2.pl>
	 <472D1DC2.9000106@o2.pl> <1194220693.4438.75.camel@localhost>
	 <20071105091231.GA1933@ff.dom.local>
	 <1194267561.2987.141.camel@localhost.localdomain>
	 <20071105135246.GB1933@ff.dom.local> <1194271589.4438.113.camel@localhost>
	 <1194283888.2987.186.camel@localhost.localdomain> <472F85F0.8060205@o2.pl>
	 <1194301667.4430.28.camel@localhost> <472FAF29.7050704@o2.pl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Rendec.iNES.RO ([80.86.127.25]:51306 "EHLO ns.rendec.ines.ro"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750802AbXKFJEs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2007 04:04:48 -0500
In-Reply-To: <472FAF29.7050704@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-11-06 at 01:02 +0100, Jarek Poplawski wrote:
> > I meant that it didnt seem necessary to me you have to do the conversion
> > back and forth of the hmask as you do in the u32_change(). The basis of
> > the patch i posted - which is based on yours - is to remove that change.
> > If that doesnt work, please just send your patch as is and we can think
> > of optimization later.

Yup, you're right. Bitwise anding is the same regardless of the byte
ordering of the operands. As long as you don't have one operand in host
order and the other in net order, it's ok.

However, Jarek's computations with his mask and your patch seemed
correct to me yesterday. And I think I know the answer: data must be
changed to host order _before_ shifting. I mean something like this:

static __inline__ unsigned u32_hash_fold(u32 key, struct tc_u32_sel
*sel, u8 fshift)
{
       unsigned h = ntohl(key & sel->hmask) >> fshift;
       return h;
}

And everything else remains unchanged (except for the ntohl() applied to
hmask before computing fshift). In other words, the idea behind your
patch now seems to be right (it's easier not to convert the hmask back
and forth as long as ntohl() in u32_hash_fold() is applied before
shifting).

> > On paper i get the same result with the new or old scheme for the bucket selection.
> > As i stated on the patch - i never did test the theory.

Well, neither did I (about what I stated above). But still I think,
Jarek was right yesterday and I can't figure out how it worked for you
on paper. How about this new version?

> In Radu's patch all calculations are done with data in host order, and
> still only this one transformation on the fast path. In your version orders
> are mixed, and this makes a difference. And, since the old scheme gives
> wrong result on little endian, I don't get it why you would want it again?
> So, with your patch with the same address and mask: 00.00.0f.f0 (host order
> on little endian) we have:
> 
> on big endian (net and host order):
> f0.0f.00.00 >> 4  gives: ff.00.00.00 with lsb: ff
> on little endian (net order):
> f0.0f.00.00 >> 4  gives: 0f.00.0f.00 then ntohl: 00.0f.00.0f with lsb: 0f
> on little endian with Radu's patch (host order):
> 00.00.0f.f0 >> 4  gives: 00.00.00.ff with lsb: ff

Ok, but now (moving ntohl() before shifting), it's like this:
ntohl(f0.0f.00.00) gives: 00.00.0f.f0, then >>4 gives 00.00.00.ff

> >> Radu, as far as I know Jamal (from reading) he most probably is busy with
> >> some conference! 
> > 
> > I actually have a day job and have to show up and meet TheMan, Jarek;->
> > Most of the days at work, i dont have time to look at external email
> > account - but you can bet all horses you own i will get back to you
> > within a few hours if you CC me on email.
> 
> 
> No offence! I've thought Radu gets a bit impatient, and don't know if he
> knows about your scientific and international achievements. On the other
> hand I can't imagine why anybody would ever like to go out of Canada!
> (Btw, in Polish the second meaning of Kanada is something like paradise
> or extreme welfare.) And, on the other hand, I'm very honoured, but I'm
> a really modest guy, far from this universities' high life here...

Actually I'm not impatient at all, because the shaping machine at the
ISP where I work is already patched with my original patch, and cpu
usage has gone from 100% to 8% after implementing hashes ;->

Still, I thought it would be a good idea to share what I found out with
the maintainers and have it fixed in the next kernel release. Now all I
want is to help you out fixing it "right" and test it. And... who
knows... if it's fixed in the official kernel, I won't need to bother
patching if i upgrade my machine ;->

BTW, I also have a steady job and don't have much time there to work on
the kernel. It's ok.

> >> Since these patches aren't so big I think you could
> >> try Jamal's at first, and if it doesn't work, and nothing new from Jamal
> >> in the meantime, resend your version. Cutdown in u32_change() seems to
> >> add more to the fastpath, but maybe Jamal thinks about something else.
> > 
> > I mean do most work on slow/config path.

Well, I think it's pretty clear now: I'll try my version of Jamal's
patch :) But not right now, because I also have to show up at work.
 
Cheers,

Radu Rendec



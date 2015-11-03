From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [GIT] Networking
Date: Tue, 3 Nov 2015 12:44:51 -0800
Message-ID: <CA+55aFzSD=H8pAP7B48HCCdjiB3R-Zvx3Dn=x-BjyiL+3UBeiw@mail.gmail.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
	<CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
	<5637C8DF.800@kernel.org>
	<CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
	<CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
	<CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
	<1446512176.17404.30.camel@kernel.crashing.org>
	<CA+55aFxas=6fg2LtcLjDB3jM9cHBj=7PnDf-8J31jc3yXNpXNQ@mail.gmail.com>
	<CALCETrUijiLwtYRwc-UHPkuhh+PoMh0scwffewuJ+7wRBR=Jfg@mail.gmail.com>
	<CA+55aFxgr=VteHvxj7EY===QbchRdLY56r7cyFxSnuF_G0rqVA@mail.gmail.com>
	<1446555200.1870849.427743457.63139285@webmail.messagingengine.com>
	<CA+55aFw-pzoSNnO_eot1c2ZJOWKrFeRhXw4oQQS9dwt4NziHfQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@amacapital.net>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFw-pzoSNnO_eot1c2ZJOWKrFeRhXw4oQQS9dwt4NziHfQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 3, 2015 at 12:05 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>      result = add_overflow(
>         mul_overflow(sec, SEC_CONVERSION, &overflow),
>         mul_overflow(nsec, NSEC_CONVERSION, &overflow),
>         &overflow);
>
>      return overflow ? MAX_JIFFIES : result;

Thinking more about this example, I think the gcc interface for
multiplication overflow is fine.

It would end up something like

    if (mul_overflow(sec, SEC_CONVERSION, &sec))
        return MAX_JIFFY_OFFSET;
    if (mul_overflow(nsec, NSEC_CONVERSION, &nsec))
        return MAX_JIFFY_OFFSET;
    sum = sec + nsec;
    if (sum < sec || sum > MAX_JIFFY_OFFSET)
        return MAX_JIFFY_OFFSET;
    return sum;

and that doesn't look horribly ugly to me.

That said, I do wonder how many of our interfaces really want
overflow, and how many just want saturation (or even clamping to a
maximum value).

For example, one of the *common* cases of multiplication overflow we
have had is for memory allocation where we do things like

    buffer = kmalloc(sizeof(something) * nr, GFP_KERNEL);

and we've fixed them by moving them to 'kcalloc()'. But as with the
jiffies conversion above, it would actually be sufficient to just
saturate to a maximum value instead, and depending on that causing the
allocation to fail.

So it may actually be that most users really don't even *want* "overflow".

Does anybody have any particular other "uhhuh, overflow in
multiplication" issues in mind? Because the interface for a saturating
multiplication (or addition, for that matter) would actually be much
easier. And would be trivial to have as an inline asm for
compatibility with older versions of gcc too.

Then you could just do that jiffies conversion - or allocation, for
that matter - without any special overflow handling at all. Doing

    buf = kmalloc(sat_mul(sizeof(x), nr), GFP_KERNEL);

would just magically work.

And the above jiffies conversion would still want to clamp things to
MAX_JIFFY_OFFSET (because we consider "jiffies" to be an offset from
now, and while it's "unsigned long", we clamp the offset to half the
range), but it would still be a rather natural model for it too.

                    Linus

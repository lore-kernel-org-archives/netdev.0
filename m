From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [GIT] Networking
Date: Mon, 2 Nov 2015 17:58:29 -0800
Message-ID: <CALCETrUijiLwtYRwc-UHPkuhh+PoMh0scwffewuJ+7wRBR=Jfg@mail.gmail.com>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
 <CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
 <5637C8DF.800@kernel.org> <CA+55aFwxDSYSB=bBfCxLadgCmFiOzAi0T0JHLFLK5nkR6cm8tg@mail.gmail.com>
 <CA+55aFy6nC9tQFE_kRrF-YS9N7Jp18CnSxsLNcnAykNLyXQUtg@mail.gmail.com>
 <CALCETrUxU_AVcQheeCXc0qTh=o2tmDbDct27QfTCb_+G6qc3gQ@mail.gmail.com>
 <1446512176.17404.30.camel@kernel.crashing.org> <CA+55aFxas=6fg2LtcLjDB3jM9cHBj=7PnDf-8J31jc3yXNpXNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Andy Lutomirski <luto@kernel.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Sasha Levin <sasha.levin@oracle.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFxas=6fg2LtcLjDB3jM9cHBj=7PnDf-8J31jc3yXNpXNQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 2, 2015 at 5:54 PM, Linus Torvalds
<torvalds@linux-foundation.org> wrote:
>
> The biggest problem - and where the compiler could actually help us -
> tends to be multiplication overflows. We have several (not *many*, but
> certainly more than just a couple) cases where we simply check by
> dividing MAX_INT or something.
>
> See for example kmalloc_array(), which does
>
>         if (size != 0 && n > SIZE_MAX / size)
>                 return NULL;
>
> exactly to avoid the overflow when it does the "n*size" allocation.
>
> So for multiplication, we really *could* use overflow logic. It's not
> horribly common, but it definitely happens.
>

Based in part on an old patch by Sasha, what if we relied on CSE:

if (mul_would_overflow(size, n))
  return NULL;
do_something_with(size * n);

I haven't checked, but it would be sad if gcc couldn't optimize this
correctly if we use the builtins.

The downside is that I don't see off the top of my head how this could
be implemented using inline asm if we want a fast fallback when the
builtins aren't available.

--Andy

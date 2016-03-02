From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [patch] net: moxa: fix an error code
Date: Wed, 02 Mar 2016 13:42:41 +0100
Message-ID: <4115115.4JnjLJnnpJ@wuerfel>
References: <20160302101110.GI5533@mwanda> <2743496.LmeGdM2Ipd@wuerfel> <20160302121526.GS5273@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jonas Jensen <jonas.jensen@gmail.com>,
	Luis de Bethencourt <luis@debethencourt.com>,
	=?ISO-8859-1?Q?fran=E7ois?= romieu <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160302121526.GS5273@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 02 March 2016 15:15:26 Dan Carpenter wrote:
> On Wed, Mar 02, 2016 at 12:36:05PM +0100, Arnd Bergmann wrote:
> > The uninitialized warning here is about a type mismatch preventing
> > gcc from noticing that two conditions are the same, I'm not sure
> > if this is a bug in gcc, or required by the C standard.
> 
> I wouldn't call it a bug, because everyone has to make trade offs
> between how fast the program runs and how accurate it is.  And trade
> offs between how ambitious your warnings are vs how many false positives
> you can tolerate.
> 
> Anyway, I feel like we should just work around GCC on a case by case
> basis instead of always using PTR_ERR_OR_ZERO().  The next version of
> GCC will fix some false positives and introduce new ones...  Next time
> using PTR_ERR_OR_ZERO() could cause warnings instead of fixing them.

It depends on whether we think the PTR_ERR_OR_ZERO() actually makes
the code more readable too. I've actually come to like it now,
the main downside being that it looks a lot like IS_ERR_OR_NULL()
which is very bad style and should be avoided at all cost. ;-)

I can also see how PTR_ERR_OR_ZERO() is easier for the compiler
to understand than IS_ERR()+PTR_ERR() and can't think of a case
where it would result in worse object code or extra (false
positive) warnings.

> Smatch works in a different way and it parse the code correctly.  But
> Smatch is slow and sometimes runs out of memory and gives up trying to
> parse large functions.  Smatch sees the two returns and tries to figure
> out the implications of each (uninitialized vs initialized).  If you
> change the code to:
> 
>         error = PTR_ERR_OR_ZERO(hash);
> 
>         if (!error)
>                 *leaf_out = be64_to_cpu(*(hash + index));
> 
>         return error;
> 
> then Smatch still breaks that up into two separate returns which imply
> initialized vs uninitialized.

Right, so it does the right thing, and it presumably understands
that 'if (error)' is the same as 'if (error < 0)' and
'if (IS_ERR_VALUE(error)', right? I think that is where gcc
gets it wrong.

	Arnd

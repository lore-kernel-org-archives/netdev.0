From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: net/sctp/sm_make_chunk.c alignment problems on parisc64
Date: Fri, 19 Sep 2003 15:15:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309191440320.4758-100000@localhost.localdomain>
References: <20030918195525.28c17cb1.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: acme@conectiva.com.br, <netdev@oss.sgi.com>,
        <lksctp-developers@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030918195525.28c17cb1.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 18 Sep 2003, David S. Miller wrote:

> On Wed, 17 Sep 2003 16:06:18 -0700 (PDT)
> Sridhar Samudrala <sri@us.ibm.com> wrote:
> 
> > I don't see this problem on i386, ia64 or ppc64. Can someone
> > familiar with parisc64 provide more details or submit a a patch to
> > fix this problem?
> 
> As an example, if you have an structure member of type "char":
> 
> struct foo {
> 	char	a;
> 	char	b[4];
> };
> 
> And then try to do something like this:
> 
> 	struct foo *p;
> 	unsigned int *v;
> 
> 	v = (unsigned int *) (&p->b[0]);
> 	*v = 0;
> 
> The build is going to explode on parisc because this simply is not
> allowed.  You cannot access a structure member as an object which
> has larger alignment than is guarenteed for the type that member
> has.
> 
> In the above example we're trying to access with 'unsigned int'
> alignment a member which is only guarenteed to have the alignment
> for a 'char'.
 

Thanks for explaining with an example. 

But unfortunately i am not able see this problem with a parisc64 cross compiler 
on i386. So it makes it hard to debug or fix it. Looks like this happens only
when building natively on a parisc64 machine which i don't have access to.

>From the following original note from Arnaldo
----------------------------------------- 
CC [M]  net/sctp/sm_make_chunk.o
{standard input}: Assembler messages:
{standard input}:2386: Error: Field not properly aligned [8] (52).
{standard input}:2386: Error: Invalid operands
{standard input}:2398: Error: Field not properly aligned [8] (52).
{standard input}:2398: Error: Invalid operands
make[2]: *** [net/sctp/sm_make_chunk.o] Error 1
make[1]: *** [net/sctp] Error 2
make: *** [net] Error 2

it happens in the sctp_pack_cookie function.
----------------------------------------- 

I am not able to figure out the exact code which is causing this problem as
the line numbers reported seem to correspond to the assembled file.

I am guessing that the following lines in sctp_pack_cookie() may be the
suspects.

        /* Copy the peer's init packet.  */
        memcpy(&cookie->c.peer_init[0], init_chunk->chunk_hdr,
               ntohs(init_chunk->chunk_hdr->length));

        /* Copy the raw local address list of the association. */
        memcpy((__u8 *)&cookie->c.peer_init[0] +
               ntohs(init_chunk->chunk_hdr->length), raw_addrs, addrs_len);


Am i right? But here, i don't see any accesses to a member as an object which
has larger alignment.
If so, is there an easy way to fix these assembler errors on parisc64? 

Also while reviewing the code in sctp_pack_cookie(), i noticed a structure
copy. Are structure copies portable across all the archictectures? Should we
replace it with a memcpy?

Thanks
Sridhar

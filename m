From: Bruce Allan <bwa@us.ibm.com>
Subject: Re: [PATCH] subset of RFC2553
Date: 18 Feb 2003 18:32:20 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1045621941.1253.21.camel@w-bwa1.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lksctp-developers@lists.sourceforge.net, linux-net@vger.kernel.org,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[This message was originally sent as a private response to Dave and
others.  I am resending it to the original audience and apologize if the
private response was the incorrect thing to do - just trying to reduce
bandwidth ;-] 

Hi Dave,

Thanks for your comments on the patch. As for the definition of struct
sockaddr_storage, it was taken verbatim from the RFC and if I understand
it correctly the use of the two pad fields and the __ss_align field are
to force the structure to be aligned on a 64-bit boundary, be guaranteed
large enough to hold anything up to the size specified by __SS_MAXSIZE,
_and_ make it obvious what fills up the entire structure (i.e. no
surprise padding put in by the compiler).  There are two requirements
for this structure described in the RFC that it be:
"- Large enough to accommodate all supported protocol-specific address
structures.
- Aligned at an appropriate boundary so that pointers to it can be cast
as pointers to protocol specific address structures and used to access
the fields of those structures without alignment problems."

See below for more comments/questions...

On Wed, 2003-02-12 at 21:43, David S. Miller wrote:
>    From: Bruce Allan <bwa@us.ibm.com>
>    Date: 12 Feb 2003 15:15:39 -0800
> 
> I don't like how sockaddr_storage works, so you'll have to clean
> it up before we move it to a generic spot.
> 
>    +struct sockaddr_storage {
>    +  sa_family_t  ss_family;                 /* address family */
>    +  /* Following fields are implementation specific */
>    +  char      __ss_pad1[_SS_PAD1SIZE];
>    +                          /* 6 byte pad, this is to make
implementation */
>    +                          /* specific pad up to alignment field
that */
>    +                          /* follows explicit in the data
structure */
>    +  int64_t   __ss_align;   /* field to force desired structure */
>    +                          /* storage alignment */
>    +  char      __ss_pad2[_SS_PAD2SIZE];
>    +                          /* 112 byte pad to achieve desired size,
*/
>    +                          /* _SS_MAXSIZE value minus size of
ss_family */
>    +                          /* __ss_pad1, __ss_align fields is 112
*/
>    +};
> 
> All of this pad stuff is really unnecessary, just specify ss_family
> and then "stuff" where "stuff" can be something like "char __data[0];"
> Then you can add "attribute((aligned(64)))" or whatever to the
> declaration as well.
If you mean something like:
struct sockaddr_storage {
	sa_family_t	ss_family;
	char		__data[0] __attribute__ ((aligned(128)));
};
This will provide a 128-byte structure, but it is also aligned on a
128-byte boundary.  I don't think it should necessarily have that
constraint.

How about this instead (a combination of your comment above and glibc's
definition of sockaddr_storage):
#define _SS_MAXSIZE	128
#define _ALIGNSIZE	(sizeof(struct sockaddr *))
#if ULONG_MAX > 0xffffffff
#define __ss_aligntype	__u64
#else
#define __ss_aligntype	__u32
#endif
struct sockaddr_storage {
	sa_family_t	ss_family;
	__ss_aligntype	__data[(_SS_MAXSIZE/sizeof(__ss_aligntype))-1];
} __attribute__ ((aligned(_ALIGNSIZE)));

This will provide a _SS_MAXSIZE byte structure aligned properly for any
32- or 64-bit architecture (eg. on a 4-byte boundary on i386) which
satisfies both requirements from the RFC mentioned above.  Of course,
there will be hidden padding between ss_family and __data introduced by
the compiler.
> 
> And if you're going to put some 64-bit type in here, use "__u64"
> which actually makes you consistent with the rest of the kernel.
Done.
> 
> You could also do something like:
>       __u64   data[_SS_MAXSIZE / sizeof(__u64)];
This wouldn't allow for use of ss_family.
> 
> Anything but this pad stuff...
We also thought of using a union such as:
struct sockaddr_storage {
	union {
		struct sockaddr		sa;
		struct sockaddr_in	sin;
		struct sockaddr_in6	sin6;
		struct sockaddr_un	sun;
		/* etc.Should include all protocol specific
		 * address structures */
	} ss;
} __attribute__ ((aligned(_ALIGNSIZE)));
which would only be as large as the biggest protocol specific address
structure and aligned properly, but would make for some unusual syntax
during it's use not to mention it doesn't follow the RFC all that
closely (doesn't provide for ss_family for instance).

Any preferences, additional thoughts or comments?

Thanks again,
-- 
Bruce Allan
Linux Technology Center
IBM Corporation, Beaverton OR

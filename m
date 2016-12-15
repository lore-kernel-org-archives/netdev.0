From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 1/4] siphash: add cryptographically secure hashtable
 function
Date: Thu, 15 Dec 2016 09:31:25 +0100
Message-ID: <f1ab5685-f8af-5f58-a217-fe53262ecf45@stressinduktion.org>
References: <20161214035927.30004-1-Jason@zx2c4.com>
 <CAHmME9q9ffdtWRbzyMO1ktTdtEFdfumTfojTTNLXFhoa+R+MWQ@mail.gmail.com>
 <8ea3fdff-23c4-b81d-2588-44549bd2d8c1@stressinduktion.org>
 <CAHmME9r8-JMqkOdz4PLgF13qYGk8XAmEjGep40k3GVYfUS_sPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        Netdev <netdev@vger.kernel.org>,
        kernel-hardening@lists.openwall.com,
        Jean-Philippe Aumasson <jeanphilippe.aumasson@gmail.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        "Daniel J . Bernstein" <djb@cr.yp.to>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Eric Biggers <ebiggers3@gmail.com>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <CAHmME9r8-JMqkOdz4PLgF13qYGk8XAmEjGep40k3GVYfUS_sPw@mail.gmail.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15.12.2016 00:29, Jason A. Donenfeld wrote:
> Hi Hannes,
> 
> On Wed, Dec 14, 2016 at 11:03 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> I fear that the alignment requirement will be a source of bugs on 32 bit
>> machines, where you cannot even simply take a well aligned struct on a
>> stack and put it into the normal siphash(aligned) function without
>> adding alignment annotations everywhere. Even blocks returned from
>> kmalloc on 32 bit are not aligned to 64 bit.
> 
> That's what the "__aligned(SIPHASH24_ALIGNMENT)" attribute is for. The
> aligned siphash function will be for structs explicitly made for
> siphash consumption. For everything else there's siphash_unaligned.

So in case you have a pointer from somewhere on 32 bit you can
essentially only guarantee it has natural alignment or max. native
alignment (based on the arch). gcc only fulfills your request for
alignment when you allocate on the stack (minus gcc bugs).

Let's say you get a pointer from somewhere, maybe embedded in a struct,
which came from kmalloc. kmalloc doesn't care about aligned attribute,
it will align according to architecture description. That said, if you
want to hash that, you would need manually align the memory returned
from kmalloc or make sure the the data is more than naturally aligned on
that architecture.

>> Can we do this a runtime check and just have one function (siphash)
>> dealing with that?
> 
> Seems like the runtime branching on the aligned function would be bad
> for performance, when we likely know at compile time if it's going to
> be aligned or not. I suppose we could add that check just to the
> unaligned version, and rename it to "maybe_unaligned"? Is this what
> you have in mind?

I argue that you mostly don't know at compile time if it is correctly
aligned if the alignment requirements are larger than the natural ones.

Also, we don't even have that for memcpy, even we use it probably much
more than hashing, so I think this is overkill.

Bye,
Hannes

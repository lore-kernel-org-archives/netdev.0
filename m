From: Andy Lutomirski <luto@kernel.org>
Subject: Re: [GIT] Networking
Date: Mon, 2 Nov 2015 12:34:39 -0800
Message-ID: <5637C8DF.800@kernel.org>
References: <20151027.233235.1641084823622810663.davem@davemloft.net>
 <CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFx0o8e9J6ojHYjvOA5aRnKoW5j10fh76Ks1=VegPc4k6w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/28/2015 02:39 AM, Linus Torvalds wrote:
>
> I'm sorry, but we don't add idiotic new interfaces like this for
> idiotic new code like that.

As one of the people who encouraged gcc to add this interface, I'll 
speak up in its favor:

Getting overflow checking right in more complicated cases is a PITA. 
I'll admit that the "subtract from an unsigned integer if it won't go 
negative" isn't particularly useful, but there are other cases in which 
it's much more useful.

The one I care about the most is for multiplication.  Witness the 
never-ending debates about the proper way to implement things like 
kmalloc_array.  We currently do:

static inline void *kmalloc_array(size_t n, size_t size, gfp_t flags)
{
         if (size != 0 && n > SIZE_MAX / size)
                 return NULL;
         return __kmalloc(n * size, flags);
}

This is correct, and it's even reasonably efficient if size is a 
compile-time constant.  (On x86, it still might not be quite optimal, 
since there'll be an extra cmp instruction.  Sure, the difference could 
easily be a cycle or even less.)

But if size is not a constant, then, unless the compiler is quite 
clever, this ends up generating a division, and that sucks.

If we were willing to do:

size_t total_bytes;
#if efficient_overflow_detection_works
if (__builtin_mul_overflow(n, size, &total_bytes))
         return NULL;
#else
/* existing check goes here */
total_bytes = n * size;
#endif
return __kmalloc(n * size, flags);

then we get optimal code generation on new compilers and the result 
isn't even that ugly to look at.

For compiler flag settings in which signed overflow can cause subtle 
disasters, the signed addition overflow helpers can be nice, too.

--Andy

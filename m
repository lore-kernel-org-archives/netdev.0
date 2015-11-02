From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Mon, 2 Nov 2015 06:22:40 +0000
Message-ID: <20151102062240.GQ22011@ZenIV.linux.org.uk>
References: <20151030210215.GI22011@ZenIV.linux.org.uk>
 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
 <20151030223317.GK22011@ZenIV.linux.org.uk>
 <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
 <20151031193449.GM22011@ZenIV.linux.org.uk>
 <CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
 <20151031202929.GN22011@ZenIV.linux.org.uk>
 <20151102002421.GP22011@ZenIV.linux.org.uk>
 <1446430483.6254.114.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446430483.6254.114.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 01, 2015 at 06:14:43PM -0800, Eric Dumazet wrote:
> On Mon, 2015-11-02 at 00:24 +0000, Al Viro wrote:
> 
> > This ought to be a bit cleaner.  Eric, could you test the variant below on your
> > setup?
> 
> Sure !
> 
> 5 runs of :
> lpaa24:~# taskset ff0ff ./opensock -t 16 -n 10000000 -l 10
> 
> total = 4386311
> total = 4560402
> total = 4437309
> total = 4516227
> total = 4478778

Umm...  With Linus' variant it was what, around 4000000?  +10% or so, then...

> With 48 threads :
> 
> ./opensock -t 48 -n 10000000 -l 10
> total = 4940245
> total = 4848513
> total = 4813153
> total = 4813946
> total = 5127804

And that - +40%?  Interesting...  And it looks like at 48 threads you are
still seeing arseloads of contention, but apparently less than with Linus'
variant...  What if you throw the __clear_close_on_exec() patch on
top of that?

Looks like it's spending less time under ->files_lock...  Could you get
information on fs/file.o hotspots?

From: "David S. Miller" <davem@redhat.com>
Subject: Re: Linux 2.6.0-test9
Date: Sun, 26 Oct 2003 22:43:58 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031026224358.233e6d1a.davem@redhat.com>
References: <Pine.LNX.4.44.0310261607230.3157-100000@home.osdl.org>
	<Pine.LNX.4.44.0310261623000.3157-100000@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Andries.Brouwer@cwi.nl, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.44.0310261623000.3157-100000@home.osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 26 Oct 2003 16:28:11 -0800 (PST)
Linus Torvalds <torvalds@osdl.org> wrote:

> But reverting the change is clearly the "safer" thing to do, I just worry 
> that Alexey might have had a real reason for tryign to avoid the EINTR in 
> the first place (for non-URG data).

I'd like to hear something from Alexey first.

The problem we were trying to deal with was that when data
is available to read a lot of people were complaining that
we return -EINTR and no other system does this.

This is heavily inconsistent with how we handle every other
type of socket error.  In all other cases, a read() when data
is available will succeed until the very last byte is sucked
out of the socket, then any subsequent read() call after the
queue is emptied will return the error.

But I am starting to see that URG is different.  It is not like
other socket errors that halt the socket and make no new data
arrive after it happens.  Rather, URG can happen just about anywhere
and more data can continue to flow into the socket buffers.

In fact, this means that our change can result in an application
can never see the error if data continues to arrive faster than
the application can pull it out, see?

Alexey, I think we did not understand this case fully when making this
change.

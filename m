From: David Miller <davem@davemloft.net>
Subject: Re: netlink backwards compatibility in userspace tools
Date: Sun, 08 Oct 2017 21:47:26 -0700 (PDT)
Message-ID: <20171008.214726.1977368725573365543.davem@davemloft.net>
References: <CAHmME9oixZtPVdH24KJQ9NaTuf_ECAOoHwQhuA+Fy-BX+F_3dw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        dkg@fifthhorseman.net
To: Jason@zx2c4.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHmME9oixZtPVdH24KJQ9NaTuf_ECAOoHwQhuA+Fy-BX+F_3dw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Fri, 29 Sep 2017 12:22:42 +0200

> One handy aspect of Netlink is that it's backwards compatible. This
> means that you can run old userspace utilities on new kernels, even if
> the new kernel supports new features and netlink attributes. The wire
> format is stable enough that the data marshaled can be extended
> without breaking compat. Neat.
> 
> I was wondering, though, what you think the best stance is toward
> these old userspace utilities. What should they do if the kernel sends
> it netlink attributes that it does not recognize? At the moment, I'm
> doing something like this:
> 
> static void warn_unrecognized(void)
> {
>     static bool once = false;
>     if (once)
>         return;
>     once = true;
>     fprintf(stderr,
>         "Warning: this program received from your kernel one or more\n"
>         "attributes that it did not recognize. It is possible that\n"
>         "this version of wg(8) is older than your kernel. You may\n"
>         "want to update this program.\n");
> }
> 
> This seems like a somewhat sensible warning, but then I wonder about
> distributions like Debian, which has a long stable life cycle, so it
> frequently has very old tools (ancient iproute2 for example). Then,
> VPS providers have these Debian images run on top of newer kernels.
> People in this situation would undoubtedly see the above warning a lot
> and not be able to do anything about it. Not horrible, but a bit
> annoying. Is this an okay annoyance? Or is it advised to just have no
> warning at all? One idea would be to put it behind an environment
> variable flag, but I don't like too many nobs.
> 
> I'm generally wondering about attitudes toward this kind of userspace
> program behavior in response to newer kernels.

Generally, yes you should simply ignore attributes you don't understand.

But we keep coming back to this issue, because it's not always the best
thing to do.

For example, let's say you have settings X and Y for object A.

User A has a newer tool and is able to set both X and Y, as well as
see them in dumps.  And let's further assume that Y's setting has some
kind of influence on the behavior of X.

User B has an older tool, and sees X but not Y because Y is not
understood by the older tool.  User B will not be able to figure out
why X is not behaving the way they expect it to, because of the loss
of information.

Similar, even more serious, issues arise when setting values.  User B
can set X and wonder why it's not doing what they expect it to do
because of setting Y which they can't even see with their tools.

For this reason it might be beneficical to at least say to the user
"Warning, I've seen one or more unrecognized netlink attributes."
so that there is at least a chance for the user to figure out what
might be happening to them.

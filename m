From: "David S. Miller" <davem@redhat.com>
Subject: Re: [2.6.0-test9] QoS HTB crash...
Date: Thu, 30 Oct 2003 13:08:59 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031030130859.605f856d.davem@redhat.com>
References: <26412.1067530225@www3.gmx.net>
	<Pine.LNX.4.33.0310302047440.11221-100000@devix>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: daniel.blueman@gmx.net, netdev@oss.sgi.com, linux-net@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: devik <devik@cdi.cz>
In-Reply-To: <Pine.LNX.4.33.0310302047440.11221-100000@devix>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 30 Oct 2003 20:50:16 +0100 (CET)
devik <devik@cdi.cz> wrote:

> thanks for the report. I know that there is an issue regarding
> HTB in 2.6.x. Please send me net/sched/sch_htb.o,
> net/sched/sch_htb.c (just to be sure) and be sure that you
> build the kernel with debugging symbols (see debugging section
> of menuconfig/xconfig).

I think the problem is the changes that were made
in 2.5.x to htb_next_rb_node().  It used to be:

static void htb_next_rb_node(rb_node_t **n)
{
        rb_node_t *p;
        if ((*n)->rb_right) {
                /* child at right. use it or its leftmost ancestor */
                *n = (*n)->rb_right;
                while ((*n)->rb_left)
                        *n = (*n)->rb_left;
                return;
        }
        while ((p = (*n)->rb_parent) != NULL) {
                /* if we've arrived from left child then we have next node */
                if (p->rb_left == *n) break;
                *n = p;
        }
        *n = p;
}

But it was changed into:

static void htb_next_rb_node(struct rb_node **n)
{
        *n = rb_next(*n);
}

This is wrong, the new code has much different side effects
than the original code.

This looks like the problem, devik what do you think?

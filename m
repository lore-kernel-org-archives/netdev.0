From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH 1/1] NET: netpoll, fix potential NULL ptr dereference
Date: Tue, 16 Mar 2010 18:22:17 +0100
Message-ID: <4B9FBE49.6010709@gmail.com>
References: <1268753394-17765-1-git-send-email-jslaby@suse.cz> <1268759527.25503.2980.camel@calx>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Slaby <jslaby@suse.cz>, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <danborkmann@googlemail.com>
To: Matt Mackall <mpm@selenic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1268759527.25503.2980.camel@calx>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/16/2010 06:12 PM, Matt Mackall wrote:
> I don't get it. The source of the branch tests for !ndev->npinfo and the
> original destination of the branch also tests for !ndev->npinfo. I don't
> see how it gets dereferenced.

Let's look at more of the context:
         if (!ndev->npinfo) {
                 npinfo = kmalloc(sizeof(*npinfo), GFP_KERNEL);
                 if (!npinfo) {         // npinfo is NULL
                         err = -ENOMEM;
                         goto release;
                 }
...
release:                           // npinfo is still NULL
         if (!ndev->npinfo) {       // condition is the same (holds)
              // dereference below: vvvvvvvvvvvvvvv
                 spin_lock_irqsave(&npinfo->rx_lock, flags);
                 list_for_each_entry_safe(npe, tmp, &npinfo->rx_np, rx) {
                         npe->dev = NULL;
                 }
                 spin_unlock_irqrestore(&npinfo->rx_lock, flags);

                 kfree(npinfo);
         }

thanks,
-- 
js

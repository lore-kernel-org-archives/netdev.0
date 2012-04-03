From: Torsten Kaiser <just.for.lkml@googlemail.com>
Subject: Re: [GIT] Networking
Date: Tue, 3 Apr 2012 21:23:55 +0200
Message-ID: <CAPVoSvTbqyEuDD5icKhXYJX-W+chfgOXchhtab7p6B9z-hCYGg@mail.gmail.com>
References: <20120402.203442.1793134339535157754.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120402.203442.1793134339535157754.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 3, 2012 at 2:34 AM, David Miller <davem@davemloft.net> wrot=
e:
> 7) virtio_net accidently uses net_ratelimit() not only on the kernel
> =A0 warning but also the statistic bump, fix from Rick Jones.

I just saw this commit land in Linus tree and I think its got its
parentheses wrong.

Old code (minus the dev_warn()-messages):
if (net_ratelimit()) {
  if (likely(capacity =3D=3D -ENOMEM)) {
    dev_warn(...);
  } else {
    dev->stats.tx_fifo_errors++;
    dev_warn(...);
  }
}

New code (minus the dev_warn()-messages):
if (likely(capacity =3D=3D -ENOMEM)) {
  if (net_ratelimit()) {
    dev_warn(...);
  } else {
    dev->stats.tx_fifo_errors++;
    if (net_ratelimit())
      dev_warn(...);
  }
}

Now it will count -ENOMEM errors that were not logged..

I think, intended was:
if (likely(capacity =3D=3D -ENOMEM)) {
  if (net_ratelimit()) {
    dev_warn(...);
  }
} else {
  dev->stats.tx_fifo_errors++;
  if (net_ratelimit())
    dev_warn(...);
}

HTH, Torsten

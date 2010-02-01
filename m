From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] irda: remove BKL from irnet open function
Date: Mon, 1 Feb 2010 22:20:30 +0100
Message-ID: <201002012220.30887.arnd@arndb.de>
References: <1265048321-8097-1-git-send-email-cascardo@holoscopio.com> <520f0cf11002011232u415146a9md3afe65af4d810a6@mail.gmail.com> <20100201203616.GJ1414@holoscopio.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: John Kacur <jkacur@gmail.com>, Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100201203616.GJ1414@holoscopio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 01 February 2010, Thadeu Lima de Souza Cascardo wrote:
> On Mon, Feb 01, 2010 at 09:32:30PM +0100, John Kacur wrote:
> > On Mon, Feb 1, 2010 at 7:18 PM, Thadeu Lima de Souza Cascardo
> > <cascardo@holoscopio.com> wrote:
> And is it possible that ioctl will be called before open returns? If it
> is, then, yes, this is not safe. But I don't really believe the case. Or
> is it?

ioctl may be called on an open file descriptor while open is called
by another thread to open a second file descriptor for the same device.

> Or is it only possible to happen with different struct file*? In that
> case, open is only allocating and initializing the irnet_socket *ap.
> Then, ioctl uses it. There is some race between the different ioctls,
> but no race between open/ioctl for different opened devices. That is, a
> process may open /dev/irnet while another process is issuing ioctls to
> its own opened /dev/irnet.

right.
 
> Besides, dev_irnet_ioctl uses the file private_data to get to the
> irnet_socket, which is the last thing the open call does. I assume doing
> an attribution to a pointer is atomic in all architectures supported by
> Linux currently, isn't it?

The pointer assignment is atomic, but it may not be synchronized to data
pointed to it. On Alpha (probably no others so far), this would result
in irnet_socket seen as uninitialized after the pointer to is can be
seen as valid if there was no locking. No architecture would read an
invalid pointer though.

I guess that what John was trying to point out actually is the fact that
you shouldn't really do the BKL removal in one function only but rather
do it for the whole driver at once. The irnet driver uses the BKL in
open, ioctl and llseek, so if you want to clean up that driver, please
introduce proper locking in the driver and do all of the three.

	Arnd

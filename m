From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V7 4/8] posix clocks: hook dynamic clocks into system
 calls
Date: Wed, 22 Dec 2010 09:21:28 +0100
Message-ID: <20101222082128.GA22845@riccoc20.at.omicron.at>
References: <cover.1292512461.git.richard.cochran@omicron.at>
 <6241238a1df55033e50b151ec9d35ba957e43d53.1292512461.git.richard.cochran@omicron.at>
 <alpine.LFD.2.00.1012162156580.12146@localhost6.localdomain6>
 <20101217070450.GB2982@riccoc20.at.omicron.at>
 <alpine.LFD.2.00.1012171010160.12146@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	John Stultz <johnstul@us.ibm.com>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:55620 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751868Ab0LVIVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 03:21:35 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1012171010160.12146@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 17, 2010 at 11:03:46AM +0100, Thomas Gleixner wrote:
> So you could do the following:
...
> static int get_posix_clock(const clockid_t id, struct posix_clock_descr *cd)
> {
> 	struct file *fp = fget(CLOCKID_TO_FD(id));
> 	int ret;
> 
> 	if (!fp || fp->f_op->open != posix_clock_open || !fp->private_data)
> 	   	return -ENODEV;
> 	ret = get_fd_clk(cd, fp);
> 	if (ret)
> 		fput(fp);
> 	return ret;
> }

In order to avoid leaking a fp reference, shouldn't this go like:

static int get_posix_clock(const clockid_t id, struct posix_clock_desc *cd)
{
	struct file *fp = fget(CLOCKID_TO_FD(id));
	int ret = -EINVAL;

	if (!fp)
		return ret;
	if (fp->f_op->open != posix_clock_open || !fp->private_data)
		goto out;
	ret = get_fd_clk(cd, fp);
out:
	if (ret)
		fput(fp);
	return ret;
}

Thanks again for your help,
Richard



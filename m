From: Jan Kasprzak <kas@fi.muni.cz>
Subject: Re: [PATCH] wan-cosa: Use memdup_user() rather than duplicating its
 implementation
Date: Wed, 24 Aug 2016 17:21:54 +0200
Message-ID: <20160824152154.GT10241@fi.muni.cz>
References: <5d335025-5f52-d4b6-0b60-89a2fd354694@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>,
        Nicolas Palix <nicolas.palix@imag.fr>
To: SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <5d335025-5f52-d4b6-0b60-89a2fd354694@users.sourceforge.net>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hello,

SF Markus Elfring wrote:
: From: Markus Elfring <elfring@users.sourceforge.net>
: Date: Sat, 20 Aug 2016 10:10:12 +0200
: 
: Reuse existing functionality from memdup_user() instead of keeping
: duplicate source code.
: 
: This issue was detected by using the Coccinelle software.

	What about the GFP_DMA attribute, which your patch deletes?
The buffer in question has to be ISA DMA-able.

	Anyway, COSA is an ancient ISA device, which is out of production
for at least 10 years. I don't have a box with ISA bus anymore, so I can't
even test the modifications of the wan/cosa.c (I do have a COSA board
itself, though :-).

	I suggest keeping the driver intact if possible, in case somebody
still uses it.

	Sincerely,

-Yenya

: Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
: ---
:  drivers/net/wan/cosa.c | 12 +++---------
:  1 file changed, 3 insertions(+), 9 deletions(-)
: 
: diff --git a/drivers/net/wan/cosa.c b/drivers/net/wan/cosa.c
: index b87fe0a..02f5809 100644
: --- a/drivers/net/wan/cosa.c
: +++ b/drivers/net/wan/cosa.c
: @@ -875,16 +875,10 @@ static ssize_t cosa_write(struct file *file,
:  	if (count > COSA_MTU)
:  		count = COSA_MTU;
:  	
: -	/* Allocate the buffer */
: -	kbuf = kmalloc(count, GFP_KERNEL|GFP_DMA);
: -	if (kbuf == NULL) {
: +	kbuf = memdup_user(buf, count);
: +	if (IS_ERR(kbuf)) {
:  		up(&chan->wsem);
: -		return -ENOMEM;
: -	}
: -	if (copy_from_user(kbuf, buf, count)) {
: -		up(&chan->wsem);
: -		kfree(kbuf);
: -		return -EFAULT;
: +		return PTR_ERR(kbuf);
:  	}
:  	chan->tx_status=0;
:  	cosa_start_tx(chan, kbuf, count);
: -- 
: 2.9.3

-- 
| Jan "Yenya" Kasprzak <kas at {fi.muni.cz - work | yenya.net - private}> |
| http://www.fi.muni.cz/~kas/                         GPG: 4096R/A45477D5 |
         Like most things in Windows, on the surface it looks great.
                         -- Jeremy Allison, A Tale of Two Standards

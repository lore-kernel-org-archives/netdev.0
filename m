From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 2/4] bas_gigaset: collapse CR/LF at end of AT response
Date: Tue, 23 Feb 2010 17:34:25 +1100
Message-ID: <20100223063425.GA28744@verge.net.au>
References: <20100221-patch-gigaset-00.tilman@imap.cc>
 <20100221-patch-gigaset-02.tilman@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100221-patch-gigaset-02.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 23, 2010 at 12:09:22AM +0100, Tilman Schmidt wrote:
> From: Tilman Schmidt <tilman@imap.cc>
> Subject: [PATCH 2/4] bas_gigaset: collapse CR/LF at end of AT response
> 
> Copy the mechanism from ser_/usb_gigaset to avoid producing
> spurious empty responses for CR/LF sequences from the device.
> Add a comment in all drivers documenting that behaviour.
> Correct an off by one error that might result in a one byte
> buffer overflow when receiving an unexpectedly long reply.
> 
> Impact: minor bugfix
> Signed-off-by: Tilman Schmidt <tilman@imap.cc>
> ---
>  drivers/isdn/gigaset/asyncdata.c |    2 +
>  drivers/isdn/gigaset/gigaset.h   |    4 +-
>  drivers/isdn/gigaset/isocdata.c  |   44 ++++++++++++++++++++++++++-----------
>  3 files changed, 35 insertions(+), 15 deletions(-)
> 
> diff --git a/drivers/isdn/gigaset/asyncdata.c b/drivers/isdn/gigaset/asyncdata.c
> index ccb2a7b..e913beb 100644
> --- a/drivers/isdn/gigaset/asyncdata.c
> +++ b/drivers/isdn/gigaset/asyncdata.c
> @@ -40,6 +40,8 @@ static inline int muststuff(unsigned char c)
>   * Append received bytes to the command response buffer and forward them
>   * line by line to the response handler. Exit whenever a mode/state change
>   * might have occurred.
> + * Note: Received lines may be terminated by CR, LF, or CR LF, which will be
> + * removed before passing the line to the response handler.
>   * Return value:
>   *	number of processed bytes
>   */
> diff --git a/drivers/isdn/gigaset/gigaset.h b/drivers/isdn/gigaset/gigaset.h
> index e963a6c..c9ccf7d 100644
> --- a/drivers/isdn/gigaset/gigaset.h
> +++ b/drivers/isdn/gigaset/gigaset.h
> @@ -38,7 +38,7 @@
>  #define GIG_COMPAT  {0, 4, 0, 0}
>  
>  #define MAX_REC_PARAMS 10	/* Max. number of params in response string */
> -#define MAX_RESP_SIZE 512	/* Max. size of a response string */
> +#define MAX_RESP_SIZE 511	/* Max. size of a response string */
>  
>  #define MAX_EVENTS 64		/* size of event queue */
>  
> @@ -498,7 +498,7 @@ struct cardstate {
>  	spinlock_t ev_lock;
>  
>  	/* current modem response */
> -	unsigned char respdata[MAX_RESP_SIZE];
> +	unsigned char respdata[MAX_RESP_SIZE+1];
>  	unsigned cbytes;
>  
>  	/* private data of hardware drivers */
> diff --git a/drivers/isdn/gigaset/isocdata.c b/drivers/isdn/gigaset/isocdata.c
> index 85394a6..16fd3bd 100644
> --- a/drivers/isdn/gigaset/isocdata.c
> +++ b/drivers/isdn/gigaset/isocdata.c
> @@ -905,29 +905,49 @@ void gigaset_isoc_receive(unsigned char *src, unsigned count,
>  
>  /* == data input =========================================================== */
>  
> +/* process a block of received bytes in command mode (mstate != MS_LOCKED)
> + * Append received bytes to the command response buffer and forward them
> + * line by line to the response handler.
> + * Note: Received lines may be terminated by CR, LF, or CR LF, which will be
> + * removed before passing the line to the response handler.
> + */
>  static void cmd_loop(unsigned char *src, int numbytes, struct inbuf_t *inbuf)
>  {
>  	struct cardstate *cs = inbuf->cs;
>  	unsigned cbytes      = cs->cbytes;
> +	unsigned char c;
>  
>  	while (numbytes--) {
> -		/* copy next character, check for end of line */
> -		switch (cs->respdata[cbytes] = *src++) {
> -		case '\r':
> +		c = *src++;
> +		switch (c) {
>  		case '\n':
> -			/* end of line */
> -			gig_dbg(DEBUG_TRANSCMD, "%s: End of Command (%d Bytes)",
> -				__func__, cbytes);
> -			if (cbytes >= MAX_RESP_SIZE - 1)

I am confused about what the value of MAX_RESP_SIZE means.
Is it a hw restriction?

It seems that up to MAX_RESP_SIZE of string-data is permitted if the line
is terminated by CR. But only MAX_RESP_SIZE -1  bytes if the line is
terminated by LF or CR LF.

> -				dev_warn(cs->dev, "response too large\n");
> +			if (cbytes == 0 && cs->respdata[0] == '\r') {
> +				/* collapse LF with preceding CR */
> +				cs->respdata[0] = 0;
> +				break;
> +			}
> +			/* --v-- fall through --v-- */
> +		case '\r':
> +			/* end of message line, pass to response handler */
> +			if (cbytes >= MAX_RESP_SIZE) {
> +				dev_warn(cs->dev, "response too large (%d)\n",
> +					 cbytes);
> +				cbytes = MAX_RESP_SIZE;
> +			}
>  			cs->cbytes = cbytes;
> +			gigaset_dbg_buffer(DEBUG_TRANSCMD, "received response",
> +					   cbytes, cs->respdata);
>  			gigaset_handle_modem_response(cs);
>  			cbytes = 0;
> +
> +			/* store EOL byte for CRLF collapsing */
> +			cs->respdata[0] = c;
>  			break;
>  		default:
> -			/* advance in line buffer, checking for overflow */
> -			if (cbytes < MAX_RESP_SIZE - 1)
> -				cbytes++;
> +			/* append to line buffer if possible */
> +			if (cbytes < MAX_RESP_SIZE)
> +				cs->respdata[cbytes] = c;
> +			cbytes++;
>  		}
>  	}
>  
> @@ -958,8 +978,6 @@ void gigaset_isoc_input(struct inbuf_t *inbuf)
>  					   numbytes, src);
>  			gigaset_if_receive(inbuf->cs, src, numbytes);
>  		} else {
> -			gigaset_dbg_buffer(DEBUG_CMD, "received response",
> -					   numbytes, src);
>  			cmd_loop(src, numbytes, inbuf);
>  		}
>  

From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH iproute2 1/2] lib/libnetlink: re malloc buff if size is
 not enough
Date: Fri, 8 Sep 2017 13:02:47 +0200
Message-ID: <20170908110247.GS2399@orbyte.nwl.cc>
References: <1504865697-27274-1-git-send-email-liuhangbin@gmail.com>
 <1504865697-27274-2-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Michal Kubecek <mkubecek@suse.cz>
To: Hangbin Liu <liuhangbin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36892 "EHLO orbyte.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752463AbdIHLCu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 8 Sep 2017 07:02:50 -0400
Content-Disposition: inline
In-Reply-To: <1504865697-27274-2-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hangbin,

On Fri, Sep 08, 2017 at 06:14:56PM +0800, Hangbin Liu wrote:
[...]
> diff --git a/lib/libnetlink.c b/lib/libnetlink.c
> index be7ac86..37cfb5a 100644
> --- a/lib/libnetlink.c
> +++ b/lib/libnetlink.c
> @@ -402,6 +402,59 @@ static void rtnl_dump_error(const struct rtnl_handle *rth,
>  	}
>  }
>  
> +static int rtnl_recvmsg(int fd, struct msghdr *msg, char **buf)
> +{
> +	struct iovec *iov;
> +	int len = -1, buf_len = 32768;
> +	char *buffer = *buf;

Isn't it possible to make 'buffer' static instead of the two 'buf'
variables in rtnl_dump_filter_l() and __rtnl_talk()? Then we would have
only a single buffer which is shared between both functions instead of
two which are independently allocated.

> +
> +	int flag = MSG_PEEK | MSG_TRUNC;
> +
> +	if (buffer == NULL)
> +re_malloc:
> +		buffer = malloc(buf_len);

I think using realloc() here is more appropriate since there is no need
to free the buffer in beforehand and calling realloc(NULL, len) is
equivalent to calling malloc(len). I think 'realloc' is also a better
name for the goto label.

> +	if (buffer == NULL) {
> +		fprintf(stderr, "malloc error: no enough buffer\n");

Minor typo here: s/no/not/

> +		return -1;

Return -ENOMEM?

> +	}
> +
> +	iov = msg->msg_iov;
> +	iov->iov_base = buffer;
> +	iov->iov_len = buf_len;
> +
> +re_recv:

Just call this 'recv'? (Not really important though.)

> +	len = recvmsg(fd, msg, flag);
> +
> +	if (len < 0) {
> +		if (errno == EINTR || errno == EAGAIN)
> +			return 0;

Instead of returning 0 (which makes callers retry), goto re_recv?

> +		fprintf(stderr, "netlink receive error %s (%d)\n",
> +			strerror(errno), errno);
> +		return len;
> +	}
> +
> +	if (len == 0) {
> +		fprintf(stderr, "EOF on netlink\n");
> +		return -1;

Return -ENODATA here? (Initially I though about -EOF, but EOF is -1 so
that would be incorrect).

> +	}
> +
> +	if (len > buf_len) {
> +		free(buffer);

If you use realloc() above, this can be dropped.

> +		buf_len = len;

For this to work you have to make buf_len static too, otherwise you will
unnecessarily reallocate the buffer. Oh, and that also requires the
single buffer (as pointed out above) because you will otherwise use a
common buf_len for both static buffers passed to this function.

> +		flag = 0;
> +		goto re_malloc;
> +	}
> +
> +	if (flag != 0) {
> +		flag = 0;
> +		goto re_recv;
> +	}
> +
> +	*buf = buffer;
> +	return len;
> +}
> +
>  int rtnl_dump_filter_l(struct rtnl_handle *rth,
>  		       const struct rtnl_dump_filter_arg *arg)
>  {
> @@ -413,31 +466,20 @@ int rtnl_dump_filter_l(struct rtnl_handle *rth,
>  		.msg_iov = &iov,
>  		.msg_iovlen = 1,
>  	};
> -	char buf[32768];
> +	static char *buf = NULL;

If you keep the static buffer in rtnl_recvmsg(), there is no need to
assign NULL here.

>  	int dump_intr = 0;
>  
> -	iov.iov_base = buf;
>  	while (1) {
>  		int status;
>  		const struct rtnl_dump_filter_arg *a;
>  		int found_done = 0;
>  		int msglen = 0;
>  
> -		iov.iov_len = sizeof(buf);
> -		status = recvmsg(rth->fd, &msg, 0);
> -
> -		if (status < 0) {
> -			if (errno == EINTR || errno == EAGAIN)
> -				continue;
> -			fprintf(stderr, "netlink receive error %s (%d)\n",
> -				strerror(errno), errno);
> -			return -1;
> -		}
> -
> -		if (status == 0) {
> -			fprintf(stderr, "EOF on netlink\n");
> -			return -1;
> -		}
> +		status = rtnl_recvmsg(rth->fd, &msg, &buf);
> +		if (status < 0)
> +			return status;
> +		else if (status == 0)
> +			continue;

When retrying inside rtnl_recvmsg(), it won't return 0 anymore. I
believe the whole 'while (1)' loop could go away then.

Everything noted for rtnl_dump_filter_l() applies to __rtnl_talk() as
well.

Thanks, Phil

From: Joseph Salisbury <joseph.salisbury@canonical.com>
Subject: Re: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in
 stream receive code
Date: Fri, 5 Feb 2016 15:06:13 -0500
Message-ID: <56B500B5.9090700@canonical.com>
References: <56B4EF04.2060407@canonical.com>
 <87r3grapyx.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org,
	"davem@davemloft.net" <davem@davemloft.net>, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87r3grapyx.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/05/2016 02:59 PM, Rainer Weikusat wrote:
> Joseph Salisbury <joseph.salisbury@canonical.com> writes:
>> Hi Rainer,
>>
>> A kernel bug report was opened against Ubuntu [0].  After a kernel
>> bisect, it was found that reverting the following commit resolved this bug:
>>
>> commit 3822b5c2fc62e3de8a0f33806ff279fb7df92432
>> Author: Rainer Weikusat <rweikusat@mobileactivedefense.com>
>> Date:   Wed Dec 16 20:09:25 2015 +0000
>>
>>     af_unix: Revert 'lock_interruptible' in stream receive code
>>
>>       
>> The regression was introduced as of v4.4-rc6.
>>
>> I was hoping to get your feedback, since you are the patch author.  Do
>> you think gathering any additional data will help diagnose this issue,
>> or would it be best to submit a revert request?
> Funny little problem :-). The code using the interruptible lock cleared
> err as side effect hence the
>
> out:
> 	return copied ? : err;
>
> at the end of unix_stream_read_generic didn't return the -ENOTSUP put
> into err at the start of the function if copied was zero after the loop
> because the size of the passed data buffer was zero.
>
> The following patch should fix this:
>
> ---------
> diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
> index 49d5093..c3e1a08 100644
> --- a/net/unix/af_unix.c
> +++ b/net/unix/af_unix.c
> @@ -2300,6 +2300,7 @@ static int unix_stream_read_generic(struct unix_stream_read_state *state)
>         else
>                 skip = 0;
>  
> +       err = 0;
>         do {
>                 int chunk;
>                 bool drop_skb;
> ----------
>
> I was just about to go the the supermarket to buy an apple when I
> received the mail. I didn't even compile the change above yet, however,
> I'll do so once I'm back and then submit something formal.
>
> Here's a test program which can be compiled with a C compiler:
> ------------
> #define _GNU_SOURCE
>     
> #include <stdlib.h>
> #include <stdio.h>
> #include <sys/socket.h>
> #include <sys/stat.h>
> #include <assert.h>
> #include <errno.h>
> #include <string.h>
>
> int main(void)
> {
>     enum { server, client, size };
>     int socket_fd[size];
>     int const opt = 1;
>
>     assert(socketpair(AF_LOCAL, SOCK_STREAM, 0, socket_fd) == 0);
>
>     char const msg[] = "A random message";
>     send(socket_fd[client], msg, sizeof msg, MSG_DONTWAIT | MSG_NOSIGNAL);
>
>     assert(setsockopt(socket_fd[server], SOL_SOCKET, SO_PASSCRED, &opt, sizeof(opt)) != -1);
>
>     union {
>         struct cmsghdr cmh;
>         char control[CMSG_SPACE(sizeof(struct ucred))];
>     } control_un;
>
>     control_un.cmh.cmsg_len = CMSG_LEN(sizeof(struct ucred));
>     control_un.cmh.cmsg_level = SOL_SOCKET;
>     control_un.cmh.cmsg_type = SCM_CREDENTIALS;
>
>     struct msghdr msgh;
>     msgh.msg_name = NULL;
>     msgh.msg_namelen = 0;
>     msgh.msg_iov = NULL;
>     msgh.msg_iovlen = 0;
>     msgh.msg_control = control_un.control;
>     msgh.msg_controllen = sizeof(control_un.control);
>
>     errno = 0;
>
>     if (recvmsg(socket_fd[server], &msgh, MSG_PEEK) == -1)
>     {
>         printf("Error: %s\n", strerror(errno));
>         exit(EXIT_FAILURE);
>     }
>     else
>     {
>         printf("Success!\n");
>         exit(EXIT_SUCCESS);
>     }
> }
Thanks for the feedback.  Just curious, was it a green apple or a red
apple? :-)

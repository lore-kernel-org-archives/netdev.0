From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [V4.4-rc6 Regression] af_unix: Revert 'lock_interruptible' in stream receive code
Date: Fri, 05 Feb 2016 21:18:04 +0000
Message-ID: <87egcqsvoz.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4EF04.2060407@canonical.com>
	<87r3grapyx.fsf@doppelsaurus.mobileactivedefense.com>
	<56B500B5.9090700@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	hannes@stressinduktion.org,
	"davem\@davemloft.net" <davem@davemloft.net>, edumazet@google.com,
	dhowells@redhat.com, ying.xue@windriver.com,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"stable\@vger.kernel.org" <stable@vger.kernel.org>
To: Joseph Salisbury <joseph.salisbury@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56B500B5.9090700@canonical.com> (Joseph Salisbury's message of
	"Fri, 5 Feb 2016 15:06:13 -0500")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joseph Salisbury <joseph.salisbury@canonical.com> writes:
> On 02/05/2016 02:59 PM, Rainer Weikusat wrote:

[recvmsg w/o iovecs returning ENOTSUP for CMSG requests]

>> Funny little problem :-). The code using the interruptible lock cleared
>> err as side effect hence the
>>
>> out:
>> 	return copied ? : err;
>>
>> at the end of unix_stream_read_generic didn't return the -ENOTSUP put
>> into err at the start of the function if copied was zero after the loop
>> because the size of the passed data buffer was zero.

There are more problems wrt handling control-message only reads in this
code. In particular, changing the test program as follows:

    if (fork() == 0) {
	sleep(1);
	send(socket_fd[client], msg, sizeof msg, MSG_DONTWAIT | MSG_NOSIGNAL);

	_exit(0);
    }

makes the recvmsg fail with EAGAIN and judging from the code (I didn't
test this yet), it will return without an error but also without
credentials if the

err = -EAGAIN
if (!timeo)
	break;

is changed to

if (!timeo) {
	err = -EAGAIN;
        break
}

because the following

mutex_lock(&u->readlock);
continue;

will cause the

do {
} while (size)

loop condition to be evaluated and since size is 0 (AIUI), the loop will
terminate immediately.

From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [net PATCH v2 2/2] net: netprio: fd passed in SCM_RIGHTS datagram
 not set correctly
Date: Tue, 14 Aug 2012 07:35:52 -0700
Message-ID: <502A6248.6090709@intel.com>
References: <20120814024320.6983.92222.stgit@jf-dev1-dcblab> <20120814024326.6983.97403.stgit@jf-dev1-dcblab> <20120814125523.GA18731@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, netdev@vger.kernel.org,
	davem@davemloft.net, linux-kernel@vger.kernel.org, joe@perches.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120814125523.GA18731@hmsreliant.think-freely.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/14/2012 5:55 AM, Neil Horman wrote:
> On Mon, Aug 13, 2012 at 07:43:27PM -0700, John Fastabend wrote:
>> A socket fd passed in a SCM_RIGHTS datagram was not getting
>> updated with the new tasks cgrp prioidx. This leaves IO on
>> the socket tagged with the old tasks priority.
>>
>> To fix this add a check in the scm recvmsg path to update the
>> sock cgrp prioidx with the new tasks value.
>>
>> Thanks to Al Viro for catching this.
>>
>> CC: Neil Horman <nhorman@tuxdriver.com>
>> Reported-by: Al Viro <viro@ZenIV.linux.org.uk>
>> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
>> ---
>>

[...]

>> @@ -281,6 +283,9 @@ void scm_detach_fds(struct msghdr *msg, struct scm_cookie *scm)
>>   		}
>>   		/* Bump the usage count and install the file. */
>>   		get_file(fp[i]);
>> +		sock = sock_from_file(fp[i], &err);
>> +		if (sock)
>> +			sock->sk->sk_cgrp_prioidx = prioidx;
> nit: You can replace the prioidx variable above and this set with a call to
> sock_update_netprioidx
>
> Neil
>

OK but then I should also make sock_update_netprioidx inline and drop
the in_interrupt() call. I'll send a v3 with this change and also a
third patch to fix a race between write_priomap and cgrp_create (also
spotted by Al Viro).

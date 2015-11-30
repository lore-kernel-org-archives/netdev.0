From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net] bridge: Only call /sbin/bridge-stp for the
	initial network namespace
Date: Mon, 30 Nov 2015 16:16:52 -0600
Message-ID: <87si3nxhd7.fsf@x220.int.ebiederm.org>
References: <565B7F7D.80208@nod.at>
	<CAGXu5jJqQKAmFK0nL69E0QOpo8WSVDqStGZo7-m7gy3vnXBa=A@mail.gmail.com>
	<87egf7183c.fsf_-_@x220.int.ebiederm.org>
	<20151130141208.516b1046@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kees Cook <keescook@chromium.org>, "kernel-hardening@lists.openwall.com"
	<kernel-hardening@lists.openwall.com>, Richard Weinberger <richard@nod.at>,
	bridge@lists.linux-foundation.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20151130141208.516b1046@xeon-e3> (Stephen Hemminger's message of
	"Mon, 30 Nov 2015 14:12:08 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <stephen@networkplumber.org> writes:

> On Mon, 30 Nov 2015 15:38:15 -0600
> ebiederm@xmission.com (Eric W. Biederman) wrote:
>
>> 
>> There is no defined mechanism to pass network namespace information
>> into /sbin/bridge-stp therefore don't even try to invoke it except
>> for bridge devices in the initial network namespace.
>> 
>> It is possible for unprivileged users to cause /sbin/bridge-stp to be
>> invoked for any network device name which if /sbin/bridge-stp does not
>> guard against unreasonable arguments or being invoked twice on the same
>> network device could cause problems.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>> ---
>>  net/bridge/br_stp_if.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>> 
>> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
>> index 5396ff08af32..742fa89528ab 100644
>> --- a/net/bridge/br_stp_if.c
>> +++ b/net/bridge/br_stp_if.c
>> @@ -142,7 +142,9 @@ static void br_stp_start(struct net_bridge *br)
>>  	char *envp[] = { NULL };
>>  	struct net_bridge_port *p;
>>  
>> -	r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
>> +	r = -ENOENT;
>> +	if (dev_net(br->dev) == &init_net)
>> +		r = call_usermodehelper(BR_STP_PROG, argv, envp, UMH_WAIT_PROC);
>
> I don't think this will cause loud screams.
> But it might break people that use containers to run virtual networks
> for testing.

I don't see how this interface can possibly be for more than the initial
network namespace.  There is no network namespace information conveyed
and /sbin/bridge-stp always runs in the initial network namespace.

Which is the point of this patch.  Don't try when the code can not work.

The only way this code could possibly work in the presence of multiple
network namespaces is if somehow the network namespace was encoded in
the device name, and then the usermode helper switched to the
appropriate network namespace.

I suspect that anyone knowledgable enough to know this interface exists
would have sent a patch to fix the kernel to give network namespace
information rather than use a horrible userspace hack like encoding the
network namespace in the device name.

> One coding nit:
> Why are you afraid of using an else?

Branch stalls.  Plus in this case an else is more lines and just plain
uglier code.

Eric

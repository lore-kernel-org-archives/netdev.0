From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH 2/2] net: Implement SO_PASSCGROUP to enable passing cgroup path
Date: Wed, 16 Apr 2014 12:13:21 -0700
Message-ID: <CALCETrUv56awd+UoO_f8LLL2FVq-Hc6Bd6iBGMqWjVGpgxgTSg@mail.gmail.com>
References: <20140416002010.GA5035@redhat.com> <CALCETrWzHYN3kKcmDTFDfGhZqE4u9+6XDtiOu5nncbK_7KKH0g@mail.gmail.com>
 <20140416.085743.1614257692560892039.davem@davemloft.net> <CALCETrVv8SPM5xjOVGy7qO2aq3FKtG2uG57J49nO7Wy0-gg0Ew@mail.gmail.com>
 <1397664837.19767.410.camel@willson.li.ssimo.org> <CALCETrXn7b6UuALpGUVoyQYfR2uzk5tj2ABV=dkvtFNgqM5sxQ@mail.gmail.com>
 <20140416180642.GG31074@redhat.com> <CALCETrVUw5+vCCONy1VTXpskbY_eZFo2CtbehwV5Mhj4d4+icw@mail.gmail.com>
 <20140416182530.GB550@redhat.com> <CALCETrUs1js3Br81ZkiQnsuWduzOiqDe3aV0K_z_zw0znSuiag@mail.gmail.com>
 <20140416190657.GK31074@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simo Sorce <ssorce@redhat.com>, David Miller <davem@davemloft.net>,
	Tejun Heo <tj@kernel.org>, Daniel Walsh <dwalsh@redhat.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	lpoetter@redhat.com, cgroups@vger.kernel.org, kay@redhat.com,
	Network Development <netdev@vger.kernel.org>
To: Vivek Goyal <vgoyal@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140416190657.GK31074@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 16, 2014 at 12:06 PM, Vivek Goyal <vgoyal@redhat.com> wrote:
> On Wed, Apr 16, 2014 at 11:35:13AM -0700, Andy Lutomirski wrote:
>> On Wed, Apr 16, 2014 at 11:25 AM, Vivek Goyal <vgoyal@redhat.com> wrote:
>> > On Wed, Apr 16, 2014 at 11:13:31AM -0700, Andy Lutomirski wrote:
>> >
>> > [..]
>> >> > Ok, so passing cgroup information is not necessarily a problem as long
>> >> > as it is not used for authentication. So say somebody is just logging
>> >> > all the client request and which cgroup client was in, that should not
>> >> > be a problem.
>> >>
>> >> Do you consider correct attribution of logging messages to be
>> >> important?  If so, then this is a kind of authentication, albeit one
>> >> where the impact of screwing it up is a bit lower.
>> >
>> > So not passing cgroup information makes attribution more correct. Just
>> > logging of information is authentication how? Both kernel and user space
>> > log message into /var/log/messages and kernel messages are prefixed with
>> > "kernel". So this somehow becomes are sort of authentication. I don't
>> > get it.
>>
>> I did a bad job of explaining what I meant.
>>
>> I think that, currently, log lines can be correctly attributed to the
>> kernel or to userspace, but determining where in userspace a log line
>> came from is a bit flaky.  One of the goals of these patches is to
>> make log attribution less flaky.  But if you want log attribution to
>> be completely correct, even in the presence of malicious programs,
>> then I think that the current patches aren't quite there.
>
> Why do you think that current patches are not there yet in the presence of
> malicious program. In your example, one program opened the socket and
> passed it to malicious program. And all the future messages are coming
> from malicious program. As long as receiver checks for SO_PASSCGROUP,
> it covers your example.

This is backwards.  The malicious program opens the socket and passes
it to an unwitting non-malicious program.  That non-malicious program
sends messages, and the logging daemon things that the non-malicious
program actually intended for these messages to end up in the system
log.

>
>>
>> Is the reason that you don't want to modify the senders because you
>> want users of syslog(3) to get the new behavior?  If so, I think it
>> would be nice to update glibc to fix that, but maybe the kernel should
>> cooperate, and maybe SO_PEERCGROUP is a decent way to handle this.
>
> Modifying every user of unix sockets to start passing cgroup information
> will make sense only if it was deemed that passing cgroup information
> is risky inherently and should be done only in selected cases.
>
> I think so far our understanding is that we can't find anything
> inherently wrong with passing cgroup information, though there might
> be some corner cases we can run into and which are not obivious right
> now.

I think I've explained why causing write(2) to start transmitting the
caller's cgroup is problematic.  Your SO_PASSCGROUP patch does that.
Your SO_PEERCGROUP patch does not.

I'm still nervous about SO_PEERCGROUP and about a variant of
SO_PASSCGROUP that used the cgroup as of the time of connect(2), but
I'm much less convinced that there's an actual problem.  My
nervousness here is more that I don't like APIs that aren't clearly
safe.

--Andy

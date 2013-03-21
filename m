From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [PATCH 1/3] net: Clean up SCM_CREDENTIALS code
Date: Thu, 21 Mar 2013 10:52:51 -0700
Message-ID: <CALCETrWaPGqcT67vtKZYQJ-_CFE46B+08qTuxJabg7HbtaDr4g@mail.gmail.com>
References: <cover.1363815201.git.luto@amacapital.net>
	<3d7ffb6d9b73971f1a526fc490ef84ef7a33eecc.1363815201.git.luto@amacapital.net>
	<87k3p1z1iq.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87k3p1z1iq.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 20, 2013 at 11:54 PM, Eric W. Biederman
<ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>
>> I was curious whether the uids, gids, and pids passed around worked
>> correctly in the presence of multiple namespaces.  I gave up trying
>> to figure it out: there are two copies of the pid (one of which has
>> type u32, which is odd), a struct cred * (!), and a separate kuid
>> and kgid.  IOW, all of the relevant data is stored twice, and it's
>> unclear which copy is used when.
>>
>> I also wondered what prevented a SO_CREDENTIALS message from being
>> recieved when the credentials weren't filled out.  Answer: not very
>> much (and there have been serious security bugs here in the past).
>>
>> So just rewrite the thing to store a pid_t relative to the init pid
>> ns, a kuid, and a kgid, and to explicitly track whether the data is
>> filled out.
>>
>> I haven't played with the secid code.  I have no idea whether it has
>> similar problems.
>>
>> I haven't benchmarked this, but it should be a respectable speedup
>> in the cases where the credentials are in use.
>
> The basic principle of no longer passing the struct cred we can
> certainly do.
>
> I am less convinced about the struct pid, but arguably that is the
> proper approach.

I agree it's not pretty.  OTOH it's faster, simpler, and I don't see
any benefit of keeping an explicit struct pid reference.  With this
approach, the only way to attack the code is to get a pid to be reused
or to impersonate pid 0 and try to confuse something.  But the other
way has the same issue, just with a shorter race window.

>
> A patch that proclaims that you didn't understand what the code was
> doing but you changed it anyway, suggests there are subtle bugs
> in there that you overlooked.

I'll improve the changelog text.  After following the code around, I
now understand what was going on.

>
> Certainly killing NETLINK_CB(sbk).ssk is a bug.

As noted in my other email, I'll drop that patch entirely.

>
> I do think there is a lot of good stuff in here and if you break this up
> into smaller patches simpler patches, and keep an eye on the speed of
> sending things messages without credentials.  I am pretty certain you
> can cook up something that is mergable.

I'm not sure how to split it up more without making it messier.  Once
the data structure changes, most of the rest of the changes have to
come along.

In any case, I won't send out a new version until I get some comments
on the code (other than the ssk thing).

--Andy

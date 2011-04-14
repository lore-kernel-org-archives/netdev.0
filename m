From: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH] NFS: Fix infinite loop in gss_create_upcall()
Date: Thu, 14 Apr 2011 22:37:16 +0200
Message-ID: <4DA75AFC.3040000@suse.cz>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>	 <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org>	 <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz>	 <4DA36758.4070203@suse.cz> <4DA36DB6.8060108@suse.cz>	 <4DA48EB0.40600@netapp.com>  <4DA4946D.5020403@suse.cz> <1302633088.4801.48.camel@lade.trondhjem.org> <4DA49B49.1020005@suse.cz> <4DA49D3A.7090800@netapp.com> <4DA49F7F.8060005@suse.cz> <4DA60AB9.1050104@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mm-commits-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DA60AB9.1050104-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/13/2011 10:42 PM, Bryan Schumaker wrote:
> On 04/12/2011 02:52 PM, Jiri Slaby wrote:
>> On 04/12/2011 08:43 PM, Bryan Schumaker wrote:
>>> On 04/12/2011 02:34 PM, Jiri Slaby wrote:
>>>> On 04/12/2011 08:31 PM, Trond Myklebust wrote:
>>>>>> Yes, it fixes the problem. But it waits 15s before it times out. This is
>>>>>> inacceptable for automounted NFS dirs.
>>>>>
>>>>> I'm still confused as to why you are hitting it at all. In the normal
>>>>> autonegotiation case, the client should be trying to use AUTH_SYS first
>>>>> and then trying rpcsec_gss if and only if that fails.
>>>>>
>>>>> Are you really exporting a filesystem using AUTH_NULL as the only
>>>>> supported flavour?
>>>>
>>>> I don't know, I connect to a nfs server which is not maintained by me.
>>>> It looks like that. How can I find out?
>>>
>>> If you're not using gss for anything, you could try rmmod-ing rpcsec_gss_krb5 (and other rpcsec_gss_* modules).
>>
>> I don't have NFS in modules. It's all built-in. And this one is
>> unconditionally selected because of CONFIG_NFS_V4.
> 
> Does this patch help?

Nope, it makes things even worse:
# mount -oro,intr XXX:/yyy /mnt/c/
<15s delay here>
mount.nfs: access denied by server while mounting XXX:/yyy

So in nfs4_proc_get_root I do:
  printk("%s: %d %u\n", __func__, i, flav_array[i]);
  status = nfs4_lookup_root_sec(server, fhandle, info, flav_array[i]);
  printk("%s: res=%d\n", __func__, status);
and get:
[   18.159818] nfs4_proc_get_root: 0 1
[   18.214872] nfs4_proc_get_root: res=-1
[   18.214875] nfs4_proc_get_root: 1 0
[   18.254636] nfs4_proc_get_root: res=-1
[   18.254639] nfs4_proc_get_root: 2 390003
[   33.252174] RPC: AUTH_GSS upcall timed out.
[   33.252177] Please check user daemon is running.
[   33.252192] nfs4_proc_get_root: res=-13

If I revert that back and do the same:
[   28.275569] nfs4_proc_get_root: 0 1
[   28.296545] nfs4_proc_get_root: res=-1
[   28.296548] nfs4_proc_get_root: 1 390003
[   43.296107] RPC: AUTH_GSS upcall timed out.
[   43.296108] Please check user daemon is running.
[   43.296121] nfs4_proc_get_root: res=-13
[   43.296122] nfs4_proc_get_root: 2 0
[   43.318201] nfs4_proc_get_root: res=-1

I.e. all methods fail. And what matters is the last retval. From NULL it
is EPERM, from GSS it is EACCESS. For EPERM, mount(8) falls back to
nfs3, for EACCESS it dies terrible death.

linux-b984:~ # strace -fe mount -s 1000 mount -oro,intr XXX:/yyy /mnt/c/
Process 2396 attached
Process 2395 suspended
[pid  2396] mount("XXX:/yyy", "/mnt/c", "nfs", MS_RDONLY,
"intr,vers=4,addr=10.20.3.2,clientaddr=10.0.2.15") = -1 EPERM (Operation
not permitted)
[pid  2396] mount("XXX:/yyy", "/mnt/c", "nfs", MS_RDONLY,
"intr,addr=10.20.3.2,vers=3,proto=tcp,mountvers=3,mountproto=udp,mountport=709")
= 0
Process 2395 resumed
Process 2396 detached
--- SIGCHLD (Child exited) @ 0 (0) ---

thanks,
-- 
js
suse labs
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

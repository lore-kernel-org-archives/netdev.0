From: Bryan Schumaker <bjschuma-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] NFS: Fix infinite loop in gss_create_upcall()
Date: Wed, 13 Apr 2011 16:42:33 -0400
Message-ID: <4DA60AB9.1050104@netapp.com>
References: <201103312224.p2VMOA5g000983@imap1.linux-foundation.org>	 <4D96E4C5.2080302@suse.cz> <1302122693.16786.0.camel@lade.trondhjem.org>	 <4D9D5CC9.2040002@suse.cz> <4DA36722.2020402@suse.cz>	 <4DA36758.4070203@suse.cz> <4DA36DB6.8060108@suse.cz>	 <4DA48EB0.40600@netapp.com>  <4DA4946D.5020403@suse.cz> <1302633088.4801.48.camel@lade.trondhjem.org> <4DA49B49.1020005@suse.cz> <4DA49D3A.7090800@netapp.com> <4DA49F7F.8060005@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	Jiri Slaby <jirislaby-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mm-commits-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ML netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DA49F7F.8060005-AlSwsSmVLrQ@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 04/12/2011 02:52 PM, Jiri Slaby wrote:
> On 04/12/2011 08:43 PM, Bryan Schumaker wrote:
>> On 04/12/2011 02:34 PM, Jiri Slaby wrote:
>>> On 04/12/2011 08:31 PM, Trond Myklebust wrote:
>>>>> Yes, it fixes the problem. But it waits 15s before it times out. This is
>>>>> inacceptable for automounted NFS dirs.
>>>>
>>>> I'm still confused as to why you are hitting it at all. In the normal
>>>> autonegotiation case, the client should be trying to use AUTH_SYS first
>>>> and then trying rpcsec_gss if and only if that fails.
>>>>
>>>> Are you really exporting a filesystem using AUTH_NULL as the only
>>>> supported flavour?
>>>
>>> I don't know, I connect to a nfs server which is not maintained by me.
>>> It looks like that. How can I find out?
>>
>> If you're not using gss for anything, you could try rmmod-ing rpcsec_gss_krb5 (and other rpcsec_gss_* modules).
> 
> I don't have NFS in modules. It's all built-in. And this one is
> unconditionally selected because of CONFIG_NFS_V4.

Does this patch help?

- Bryan

We should attempt an AUTH_NULL style mount before
trying gss flavors.  This should prevent a hang if
gss modules are loaded but the userspace program
isn't running.

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9bf41ea..4e3c16b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2218,8 +2218,8 @@ static int nfs4_proc_get_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	rpc_authflavor_t flav_array[NFS_MAX_SECFLAVORS + 2];
 
 	flav_array[0] = RPC_AUTH_UNIX;
-	len = gss_mech_list_pseudoflavors(&flav_array[1]);
-	flav_array[1+len] = RPC_AUTH_NULL;
+	flav_array[1] = RPC_AUTH_NULL;
+	len = gss_mech_list_pseudoflavors(&flav_array[2]);
 	len += 2;
 
 	for (i = 0; i < len; i++) {


> 
> regards,

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

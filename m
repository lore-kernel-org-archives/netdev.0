From: Steve Grubb <sgrubb@redhat.com>
Subject: Re: [PATCH 1/1] NetLabel: add audit support for configuration
	changes
Date: Fri, 29 Sep 2006 14:35:53 -0400
Message-ID: <200609291435.53680.sgrubb@redhat.com>
References: <20060928180326.896170000@hp.com>
	<200609291008.07290.sgrubb@redhat.com> <451D614F.8090502@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
	selinux@tycho.nsa.gov
Return-path: <linux-audit-bounces@redhat.com>
To: Paul Moore <paul.moore@hp.com>
In-Reply-To: <451D614F.8090502@hp.com>
Content-Disposition: inline
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Friday 29 September 2006 14:09, Paul Moore wrote:
> > type field is already taken for another purpose, it needs to be renam=
ed.
>
> If we can't have duplicate field names I would propose prefixing both
> these fields (and doing similar things with the other NetLabel specific
> fields) with a "cipso_" making them "cipso_doi" and "cipso_type".

That would be fine. This limits future field name collisions.

> >>+/**
> >>+ * netlbl_unlabel_acceptflg_set - Set the unlabeled accept flag
> >>+ * @value: desired value
> >>+ * @audit_secid: the LSM secid to use in the audit message
> >>+ *
> >>+ * Description:
> >>+ * Set the value of the unlabeled accept flag to @value.
> >>+ *
> >>+ */
> >>+static void netlbl_unlabel_acceptflg_set(u8 value, u32 audit_secid)
> >>+{
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0atomic_set(&netlabel_unlabel_accept_fl=
g, value);
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0netlbl_audit_nomsg((value ?
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0AU=
DIT_MAC_UNLBL_ACCEPT : AUDIT_MAC_UNLBL_DENY),
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0 audit_se=
cid);
> >
> > Looking at how this is being used, I think only 1 message type should=
 be
> > used. There are places in the audit system where we set a flag to 1 o=
r 0,
> > but only have 1 message type. We record the old and new value. So, yo=
u'd
> > need to pass that to the logger.
>
> With that in mind I would probably change the message type to
> AUDIT_MAC_UNLBL_ALLOW and use a "unlbl_accept" field; is that okay? =C2=
=A0

That would be fine. Just a quick note...we have generally been "old " to=20
indicate the previous value. Example, "backlog=3D512 old=3D256".

> >>+/**
> >>+ * netlbl_audit_start_common - Start an audit message
> >>+ * @type: audit message type
> >>+ * @secid: LSM context ID
> >>+ *
> >>+ * Description:
> >>+ * Start an audit message using the type specified in @type and fill=
 the
> >>audit + * message with some fields common to all NetLabel audit messa=
ges.
> >>Returns + * a pointer to the audit buffer on success, NULL on failure=
.
> >>+ *
> >>+ */
> >>+struct audit_buffer *netlbl_audit_start_common(int type, u32 secid)
> >>+{
> >
> > Generally, logging functions are moved into auditsc.c where the conte=
xt
> > and other functions are defined.
>
> How about leaving this for a future revision?

Come to think of it, you don't need to move it. The reason to move it is =
to=20
access the context and use helper functions related to it. But I found th=
at=20
you were using "current" which may not always be the sender. So if you ca=
nnot=20
use current, most of the stuff you are logging can't be, so the event bei=
ng=20
logged becomes simpler and you don't need to move it.

I have not traced through all the code, but if you do any security checks=
=20
before taking the rules, be careful not to use current.

> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0audit_log_format(audit_buf,
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 "netlabel: auid=
=3D%u uid=3D%u tty=3D%s pid=3D%d",
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 audit_loginuid,
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 current->uid,
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 audit_tty,
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 current->pid);
> >
> > Why are you logging all this? When we add audit rules, all that we lo=
g is
> > the auid, and subj. If we need to log all this, we should probably ha=
ve a
> > helper function that gets called by other config change loggers.
>
> If I drop the uid, tty, and pid fields will this be acceptable?

 and comm & exe, yes. Anything you were basing off of current has to go. =
The=20
audit rule logging was reduced to the credentials that are carried along =
in=20
the netlink packet since that's all you can trust. The sending process co=
uld=20
be gone by the time you get to this point in the code.

> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0audit_log_format(audit_buf, " comm=3D"=
);
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0audit_log_untrustedstring(audit_buf, a=
udit_comm);
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (current->mm) {
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0down_read(&current->mm->mmap_sem);
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0vma =3D current->mm->mmap;
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0while (vma) {
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if ((vma->vm_fla=
gs & VM_EXECUTABLE) &&
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0 =C2=A0vm=
a->vm_file) {
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0audit_log_d_path(audit_buf,
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 " exe=3D",
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 vma->vm_file->f_dentr=
y,
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 vma->vm_file->f_vfsmn=
t);
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0break;
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0vma =3D vma->vm_=
next;
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0}
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0up_read(&current->mm->mmap_sem);
> >>+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> >>+
> >
> > If this function was moved inside auditsc.c you could use a function
> > there that does this. But the question remains why all this data?
>
> In the ideal world would you prefer this to be removed?

Yes.

-Steve
